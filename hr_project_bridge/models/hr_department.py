# -*- coding: utf-8 -*-
from odoo import models, fields, api


class HrDepartment(models.Model):
    _inherit = 'hr.department'

    # ── Inverse relation to projects ──────────────────────────────────────────

    project_ids = fields.One2many(
        'project.project',
        'department_id',
        string='Projects',
    )
    project_count = fields.Integer(
        string='Projects',
        compute='_compute_project_count',
        store=True,
    )

    # ── Computes ──────────────────────────────────────────────────────────────

    @api.depends('project_ids', 'project_ids.active')
    def _compute_project_count(self):
        """
        Single read_group query — avoids N+1 pattern.
        Only counts active projects (archived projects are excluded).
        """
        data = self.env['project.project'].read_group(
            domain=[
                ('department_id', 'in', self.ids),
                ('active', '=', True),
            ],
            fields=['department_id'],
            groupby=['department_id'],
        )
        mapped = {
            item['department_id'][0]: item['department_id_count']
            for item in data
        }
        for dept in self:
            dept.project_count = mapped.get(dept.id, 0)

    # ── Actions ───────────────────────────────────────────────────────────────

    def action_open_department_projects(self):
        """
        Smart button: open all projects for this department
        using the cost-aware tree view.
        """
        self.ensure_one()
        return {
            'type': 'ir.actions.act_window',
            'name': 'Projects — %s' % self.name,
            'res_model': 'project.project',
            'view_mode': 'tree,form',
            'domain': [('department_id', '=', self.id)],
            'context': {
                'default_department_id': self.id,
                'search_default_active': True,
            },
            'views': [
                (self.env.ref(
                    'hr_project_bridge.view_project_tree_department_cost'
                ).id, 'tree'),
                (False, 'form'),
            ],
        }
