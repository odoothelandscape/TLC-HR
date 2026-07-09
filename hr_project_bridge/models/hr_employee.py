# -*- coding: utf-8 -*-
from odoo import models, fields, api


class HrEmployee(models.Model):
    _inherit = 'hr.employee'

    # ── Inverse relation to project lines ────────────────────────────────────

    project_line_ids = fields.One2many(
        'project.employee.line',
        'employee_id',
        string='Project Assignments',
    )
    project_count = fields.Integer(
        string='Projects',
        compute='_compute_project_count',
        store=True,
    )

    # ── Computes ──────────────────────────────────────────────────────────────

    @api.depends('project_line_ids')
    def _compute_project_count(self):
        """Single read_group query — avoids N+1 pattern."""
        data = self.env['project.employee.line'].read_group(
            domain=[('employee_id', 'in', self.ids)],
            fields=['employee_id'],
            groupby=['employee_id'],
        )
        mapped = {
            item['employee_id'][0]: item['employee_id_count']
            for item in data
        }
        for emp in self:
            emp.project_count = mapped.get(emp.id, 0)

    # ── Actions ───────────────────────────────────────────────────────────────

    def action_open_employee_projects(self):
        """
        Smart button: open all project assignments for this employee,
        showing project name, analytic distribution, and cost per project.
        """
        self.ensure_one()
        return {
            'type': 'ir.actions.act_window',
            'name': 'Projects — %s' % self.name,
            'res_model': 'project.employee.line',
            'view_mode': 'tree,form',
            'domain': [('employee_id', '=', self.id)],
            'context': {'default_employee_id': self.id},
            'views': [
                (self.env.ref(
                    'hr_project_bridge.view_project_employee_line_tree_employee'
                ).id, 'tree'),
                (False, 'form'),
            ],
        }
