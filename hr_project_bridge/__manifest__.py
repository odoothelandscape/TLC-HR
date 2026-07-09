# -*- coding: utf-8 -*-
{
    'name': 'HR Project Bridge — Cost Intelligence',
    'version': '19.0.1.0.0',
    'category': 'Project/Human Resources',
    'summary': 'Link Projects, Employees & Departments with real-time cost tracking',
    'description': """
        Bridge module connecting Project, HR Employee, and Department
        with live cost analytics drawn from payroll journal entries,
        accounting analytic lines, and linked budget records.

        Features:
        - Assign employees to projects with analytic distribution
        - Link each employee line to an existing Odoo Budget Line
        - Real-time cost from account.analytic.line (payroll + accounting)
        - Budget health indicator per employee and per project
        - Smart buttons on Project, Department, and Employee
        - Department view: all projects with cost and % breakdown
        - Employee view: all projects with individual cost per project
    """,
    'author': 'TLC',
    'license': 'OPL-1',
    'depends': [
        'project',        # project.project
        'hr',             # hr.employee, hr.department (includes hr.contract in Odoo 19 EE)
        'analytic',       # account.analytic.line, analytic_distribution widget
        'account',        # account.move.line, monetary fields
        'hr_timesheet',   # Timesheet analytic lines
        'account_budget', # budget.budget, budget.line (Odoo 19 EE)
    ],
    'data': [
        'security/ir.model.access.csv',
        'security/hr_project_bridge_security.xml',
        'views/project_employee_line_views.xml',
        'views/project_project_views.xml',
        'views/hr_department_views.xml',
        'views/hr_employee_views.xml',
    ],
    'installable': True,
    'application': False,
    'auto_install': False,
}
