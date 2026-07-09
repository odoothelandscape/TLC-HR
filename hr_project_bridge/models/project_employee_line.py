# -*- coding: utf-8 -*-
from odoo import models, fields, api, _
from odoo.exceptions import ValidationError
import logging

_logger = logging.getLogger(__name__)


class ProjectEmployeeLine(models.Model):
    _name = 'project.employee.line'
    _description = 'Project Employee Assignment with Cost Tracking'
    _order = 'project_id, employee_id'
    _rec_name = 'employee_id'

    # ── Relational ───────────────────────────────────────────────────────────

    project_id = fields.Many2one(
        'project.project',
        string='Project',
        required=True,
        ondelete='cascade',
        index=True,
    )
    employee_id = fields.Many2one(
        'hr.employee',
        string='Employee',
        required=True,
        ondelete='restrict',
        index=True,
    )
    department_id = fields.Many2one(
        'hr.department',
        string='Department',
        related='employee_id.department_id',
        store=True,
        readonly=True,
    )
    company_id = fields.Many2one(
        'res.company',
        related='project_id.company_id',
        store=True,
        index=True,
    )
    currency_id = fields.Many2one(
        'res.currency',
        related='company_id.currency_id',
        store=True,
    )

    # ── Analytic distribution ────────────────────────────────────────────────
    # In Odoo 19 EE, analytic_distribution is a Json field storing
    # {analytic_account_id (str): percentage (float)}.
    # The analytic_distribution widget renders the selection UI automatically.
    analytic_distribution = fields.Json(
        string='Analytic Distribution',
        required=True,
    )

    # ── Budget link ──────────────────────────────────────────────────────────
    # User selects an existing budget.line record.
    # The estimated_cost is pulled automatically from budget_line_id.budget_amount.

    budget_line_id = fields.Many2one(
        'budget.line',
        string='Budget Line',
        ondelete='set null',
        help='Select the budget line that covers this employee\'s cost on this project. '
             'The estimated cost will be pulled automatically.',
    )
    estimated_cost = fields.Monetary(
        string='Estimated Cost',
        related='budget_line_id.budget_amount',
        currency_field='currency_id',
        readonly=True,
        store=True,
        help='Automatically pulled from the selected Budget Line.',
    )

    # ── Actual cost (computed from analytic lines) ───────────────────────────
    # store=True so it can be summed in tree views and used in aggregations.
    # Recomputed when employee or analytic distribution changes.
    # Use the "Refresh Costs" button on the project form for a full live update.

    current_actual_cost = fields.Monetary(
        string='Actual Cost',
        compute='_compute_actual_cost',
        store=True,
        currency_field='currency_id',
        help='Sum of all analytic lines (payroll journal entries + accounting moves + '
             'timesheets) linked to this employee on the project\'s analytic accounts, '
             'weighted by the analytic distribution percentage.',
    )
    cost_status = fields.Selection(
        selection=[
            ('no_budget', 'No Budget'),
            ('under',     'Under Budget'),
            ('on_track',  'On Track'),
            ('over',      'Over Budget'),
        ],
        string='Status',
        compute='_compute_actual_cost',
        store=True,
        help='Compares Actual Cost against the Estimated Cost from the Budget Line.',
    )

    # ── SQL constraint ───────────────────────────────────────────────────────

    _sql_constraints = [
        (
            'unique_project_employee',
            'UNIQUE(project_id, employee_id)',
            'This employee is already assigned to this project.',
        ),
    ]

    # ── Constraints ──────────────────────────────────────────────────────────

    @api.constrains('analytic_distribution')
    def _check_analytic_distribution(self):
        """Analytic distribution is required and must sum to exactly 100%."""
        for rec in self:
            if not rec.analytic_distribution:
                raise ValidationError(_(
                    'Analytic Distribution is required for employee "%s". '
                    'Please set it before saving.',
                    rec.employee_id.name,
                ))
            total = sum(float(v) for v in rec.analytic_distribution.values())
            if abs(total - 100.0) > 0.01:
                raise ValidationError(_(
                    'Analytic Distribution for "%s" must sum to 100%%. '
                    'Current total: %.2f%%.',
                    rec.employee_id.name,
                    total,
                ))

    # ── Computes ─────────────────────────────────────────────────────────────

    @api.depends(
        'employee_id',
        'analytic_distribution',
    )
    def _compute_actual_cost(self):
        """
        Aggregate cost from account.analytic.line for this employee
        on the analytic accounts defined in analytic_distribution.

        Sources covered:
          - Payroll: confirmed payslips post journal entries → analytic lines
          - Accounting: any account.move.line with analytic distribution
          - Timesheets: hr.timesheet lines (also analytic lines)

        The amount on each analytic line is multiplied by the analytic
        distribution percentage so that employees shared across projects
        contribute proportionally to each project's cost.

        Cost status thresholds (vs budget line estimate):
          - Under   : actual <= 80% of estimate   (green)
          - On Track: actual <= 100% of estimate  (orange)
          - Over    : actual  > 100% of estimate  (red)
          - No Budget: no budget line linked      (grey)
        """
        AnalyticLine = self.env['account.analytic.line'].sudo()

        for rec in self:
            if not rec.employee_id or not rec.analytic_distribution:
                rec.current_actual_cost = 0.0
                rec.cost_status = 'no_budget'
                continue

            # Build list of analytic account IDs from the JSON distribution
            try:
                analytic_account_ids = [int(k) for k in rec.analytic_distribution.keys()]
            except (ValueError, AttributeError):
                _logger.warning(
                    'hr_project_bridge: invalid analytic_distribution on line %d', rec.id
                )
                rec.current_actual_cost = 0.0
                rec.cost_status = 'no_budget'
                continue

            if not analytic_account_ids:
                rec.current_actual_cost = 0.0
                rec.cost_status = 'no_budget'
                continue

            lines = AnalyticLine.search([
                ('employee_id', '=', rec.employee_id.id),
                ('account_id', 'in', analytic_account_ids),
            ])

            total = 0.0
            for al in lines:
                key = str(al.account_id.id)
                pct = float(rec.analytic_distribution.get(key, 0.0))
                # analytic line amounts are negative for costs (credit = cost)
                # abs() ensures we always get a positive cost figure
                total += abs(al.amount) * (pct / 100.0)

            rec.current_actual_cost = total

            # Compare against budget estimate — NOT against monthly wage
            estimate = rec.estimated_cost or 0.0
            if estimate <= 0.0:
                rec.cost_status = 'no_budget'
            elif total <= estimate * 0.80:
                rec.cost_status = 'under'
            elif total <= estimate:
                rec.cost_status = 'on_track'
            else:
                rec.cost_status = 'over'

    # ── Onchange ─────────────────────────────────────────────────────────────

    # ── Manual refresh ────────────────────────────────────────────────────────

    def action_refresh_cost(self):
        """
        Triggered by the Refresh button on the project form.
        Forces recomputation of actual cost for this record set.
        """
        self._compute_actual_cost()
