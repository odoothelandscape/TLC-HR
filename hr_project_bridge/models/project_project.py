# -*- coding: utf-8 -*-
from odoo import models, fields, api


class ProjectProject(models.Model):
    _inherit = 'project.project'

    # ── Department link ──────────────────────────────────────────────────────

    department_id = fields.Many2one(
        'hr.department',
        string='Department',
        index=True,
        tracking=True,
        help='Department responsible for this project. '
             'Visible on the Department smart button count.',
    )

    # ── Employee assignment lines ─────────────────────────────────────────────

    employee_line_ids = fields.One2many(
        'project.employee.line',
        'project_id',
        string='Employee Assignments',
    )
    employee_count = fields.Integer(
        string='Employees',
        compute='_compute_employee_count',
        store=True,
    )

    # ── Currency ──────────────────────────────────────────────────────────────

    currency_id = fields.Many2one(
        'res.currency',
        related='company_id.currency_id',
        store=True,
    )

    # ── Budget / cost summary ─────────────────────────────────────────────────
    # initial_estimate_cost: the project-level top-down budget the user enters.
    # total_estimated_cost:  sum of all budget line amounts (bottom-up from lines).
    # current_total_cost:    live actual cost summed from all employee lines.
    # budget_health uses initial_estimate_cost as primary baseline;
    # falls back to total_estimated_cost if no project-level estimate is set.

    initial_estimate_cost = fields.Monetary(
        string='Initial Estimate',
        currency_field='currency_id',
        tracking=True,
        help='Top-down project budget entered by the project manager. '
             'Used as the primary baseline for budget health calculations. '
             'If left empty, the sum of linked Budget Lines is used instead.',
    )
    total_estimated_cost = fields.Monetary(
        string='Budget Lines Total',
        compute='_compute_cost_summary',
        store=True,
        currency_field='currency_id',
        help='Sum of all Budget Line amounts linked to employee assignments.',
    )
    current_total_cost = fields.Monetary(
        string='Total Actual Cost',
        compute='_compute_cost_summary',
        store=True,
        currency_field='currency_id',
        help='Live actual cost: sum of all analytic lines for all assigned employees.',
    )
    budget_remaining = fields.Monetary(
        string='Remaining Budget',
        compute='_compute_cost_summary',
        store=True,
        currency_field='currency_id',
        help='Baseline (Initial Estimate or Budget Lines Total) minus Total Actual Cost.',
    )
    budget_variance = fields.Float(
        string='Budget Used (%)',
        compute='_compute_cost_summary',
        store=True,
        digits=(5, 1),
        help='(Total Actual Cost / Baseline) × 100. Values above 100 = over budget.',
    )
    budget_health = fields.Selection(
        selection=[
            ('no_budget', '— No Budget'),
            ('healthy',   '🟢 Healthy'),
            ('warning',   '🟡 Warning'),
            ('critical',  '🔴 Over Budget'),
        ],
        string='Budget Health',
        compute='_compute_cost_summary',
        store=True,
    )

    # ── Computes ──────────────────────────────────────────────────────────────

    @api.depends('employee_line_ids')
    def _compute_employee_count(self):
        for project in self:
            project.employee_count = len(project.employee_line_ids)

    @api.depends(
        'employee_line_ids.current_actual_cost',
        'employee_line_ids.estimated_cost',
        'initial_estimate_cost',
    )
    def _compute_cost_summary(self):
        for project in self:
            actual   = sum(project.employee_line_ids.mapped('current_actual_cost'))
            budgeted = sum(project.employee_line_ids.mapped('estimated_cost'))

            project.current_total_cost   = actual
            project.total_estimated_cost = budgeted

            # Baseline: prefer project-level initial estimate; fall back to budget lines sum
            baseline = project.initial_estimate_cost or budgeted

            if not baseline or baseline <= 0.0:
                project.budget_remaining = 0.0
                project.budget_variance  = 0.0
                project.budget_health    = 'no_budget'
                continue

            project.budget_remaining = baseline - actual
            variance = (actual / baseline) * 100.0
            project.budget_variance = variance

            if variance <= 80.0:
                project.budget_health = 'healthy'
            elif variance <= 100.0:
                project.budget_health = 'warning'
            else:
                project.budget_health = 'critical'

    # ── Actions ───────────────────────────────────────────────────────────────

    def action_open_project_employees(self):
        """Smart button: open all employee lines for this project."""
        self.ensure_one()
        return {
            'type': 'ir.actions.act_window',
            'name': 'Employees — %s' % self.name,
            'res_model': 'project.employee.line',
            'view_mode': 'tree,form',
            'domain': [('project_id', '=', self.id)],
            'context': {'default_project_id': self.id},
        }

    def action_refresh_all_costs(self):
        """
        Manual refresh: recomputes actual cost for every employee line
        on this project and returns a success notification.
        """
        self.ensure_one()
        self.employee_line_ids._compute_actual_cost()
        count = len(self.employee_line_ids)
        return {
            'type': 'ir.actions.client',
            'tag': 'display_notification',
            'params': {
                'title': 'Costs Refreshed',
                'message': 'Actual cost updated for %d employee(s).' % count,
                'type': 'success',
                'sticky': False,
            },
        }
