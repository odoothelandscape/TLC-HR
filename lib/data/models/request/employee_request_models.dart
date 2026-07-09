/// Models for the HST Employee Requests feature.
/// Backed by the hst_employee_requests REST API (see API.md).

int _toInt(dynamic v, [int def = 0]) =>
    v == null ? def : (v is int ? v : int.tryParse(v.toString()) ?? def);

double _toDouble(dynamic v, [double def = 0]) =>
    v == null ? def : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? def);

String _toStr(dynamic v, [String def = '']) =>
    v == null || v == false ? def : v.toString();

bool _toBool(dynamic v) => v == true || v == 'true' || v == 1;

class RequestCategory {
  final int id;
  final String name;
  final String description;
  final String postApprovalAction; // none | create_loan | link_loan ...
  final int fieldCount;

  RequestCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.postApprovalAction,
    required this.fieldCount,
  });

  factory RequestCategory.fromJson(Map<String, dynamic> j) => RequestCategory(
        id: _toInt(j['id']),
        name: _toStr(j['name']),
        description: _toStr(j['description']),
        postApprovalAction: _toStr(j['post_approval_action'], 'none'),
        fieldCount: _toInt(j['field_count']),
      );
}

class RequestSection {
  final int id;
  final String code;
  final String name;
  final String icon;
  final List<RequestCategory> categories;

  RequestSection({
    required this.id,
    required this.code,
    required this.name,
    required this.icon,
    required this.categories,
  });

  factory RequestSection.fromJson(Map<String, dynamic> j) => RequestSection(
        id: _toInt(j['id']),
        code: _toStr(j['code']),
        name: _toStr(j['name']),
        icon: _toStr(j['icon']),
        categories: ((j['categories'] ?? []) as List)
            .map((e) => RequestCategory.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class FieldOption {
  final dynamic id;
  final String code;
  final String label;

  FieldOption({this.id, required this.code, required this.label});

  factory FieldOption.fromJson(dynamic j) {
    if (j is Map) {
      return FieldOption(
        id: j['id'],
        code: _toStr(j['code'], _toStr(j['id'])),
        label: _toStr(j['label'], _toStr(j['name'], _toStr(j['code']))),
      );
    }
    return FieldOption(code: j.toString(), label: j.toString());
  }

  /// Value sent to the server: prefer code, fall back to id.
  dynamic get sendValue => code.isNotEmpty ? code : id;
}

class RequestField {
  final int id;
  final String code;
  final String label;
  final String type; // char|text|number|date|datetime|boolean|selection|employee|attachment
  final bool required;
  final String placeholder;
  final String help;
  final List<FieldOption> options;

  RequestField({
    required this.id,
    required this.code,
    required this.label,
    required this.type,
    required this.required,
    required this.placeholder,
    required this.help,
    required this.options,
  });

  factory RequestField.fromJson(Map<String, dynamic> j) => RequestField(
        id: _toInt(j['id']),
        code: _toStr(j['code']),
        label: _toStr(j['label']),
        type: _toStr(j['type'], 'char'),
        required: _toBool(j['required']),
        placeholder: _toStr(j['placeholder']),
        help: _toStr(j['help']),
        options:
            ((j['options'] ?? []) as List).map(FieldOption.fromJson).toList(),
      );
}

class ChainStep {
  final int sequence;
  final String roleCode;
  final String role;
  final String stepType;

  ChainStep({
    required this.sequence,
    required this.roleCode,
    required this.role,
    required this.stepType,
  });

  factory ChainStep.fromJson(Map<String, dynamic> j) => ChainStep(
        sequence: _toInt(j['sequence']),
        roleCode: _toStr(j['role_code']),
        role: _toStr(j['role']),
        stepType: _toStr(j['step_type']),
      );
}

class RoleCandidate {
  final int userId;
  final String name;

  RoleCandidate({required this.userId, required this.name});

  factory RoleCandidate.fromJson(Map<String, dynamic> j) => RoleCandidate(
        userId: _toInt(j['user_id']),
        name: _toStr(j['name']),
      );
}

class RoleChoice {
  final String roleCode;
  final String role;
  final List<RoleCandidate> candidates;

  RoleChoice({required this.roleCode, required this.role, required this.candidates});

  factory RoleChoice.fromJson(Map<String, dynamic> j) => RoleChoice(
        roleCode: _toStr(j['role_code']),
        role: _toStr(j['role']),
        candidates: ((j['candidates'] ?? []) as List)
            .map((e) => RoleCandidate.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class RunningLoan {
  final int id;
  final String name;
  final double amount;
  final double remaining;

  RunningLoan({
    required this.id,
    required this.name,
    required this.amount,
    required this.remaining,
  });

  factory RunningLoan.fromJson(Map<String, dynamic> j) => RunningLoan(
        id: _toInt(j['id']),
        name: _toStr(j['name'], _toStr(j['display_name'])),
        amount: _toDouble(j['amount'] ?? j['loan_amount']),
        remaining: _toDouble(j['remaining'] ?? j['remaining_amount'] ?? j['balance_amount']),
      );
}

class RequestFormSchema {
  final List<RequestField> fields;
  final List<ChainStep> chainPreview;
  final List<RoleChoice> roleChoices;
  final List<RunningLoan> runningLoans;

  RequestFormSchema({
    required this.fields,
    required this.chainPreview,
    required this.roleChoices,
    required this.runningLoans,
  });

  factory RequestFormSchema.fromJson(Map<String, dynamic> j) => RequestFormSchema(
        fields: ((j['fields'] ?? []) as List)
            .map((e) => RequestField.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        chainPreview: ((j['chain_preview'] ?? []) as List)
            .map((e) => ChainStep.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        roleChoices: ((j['role_choices'] ?? []) as List)
            .map((e) => RoleChoice.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        runningLoans: ((j['running_loans'] ?? []) as List)
            .map((e) => RunningLoan.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class MyRequestItem {
  final int id;
  final String name;
  final String categoryName;
  final String sectionName;
  final String status; // new | pending | approved | refused | cancel
  final String date;

  MyRequestItem({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.sectionName,
    required this.status,
    required this.date,
  });

  factory MyRequestItem.fromJson(Map<String, dynamic> j) => MyRequestItem(
        id: _toInt(j['id'] ?? j['request_id']),
        name: _toStr(j['name'], _toStr(j['display_name'])),
        categoryName: _toStr(j['category'] is Map
            ? j['category']['name']
            : (j['category_name'] ?? j['category'])),
        sectionName: _toStr(j['section'] is Map
            ? j['section']['name']
            : (j['section_name'] ?? j['section'])),
        status: _toStr(j['status'] ?? j['state'], 'new'),
        date: _toStr(j['date'] ?? j['create_date']),
      );
}

class RequestValue {
  final String code;
  final String label;
  final String type;
  final dynamic value;
  final String displayValue;

  RequestValue({
    required this.code,
    required this.label,
    required this.type,
    required this.value,
    required this.displayValue,
  });

  factory RequestValue.fromJson(Map<String, dynamic> j) => RequestValue(
        code: _toStr(j['code']),
        label: _toStr(j['label']),
        type: _toStr(j['type']),
        value: j['value'],
        displayValue: _toStr(j['display_value'], _toStr(j['value'])),
      );
}

class ApprovalChainStep {
  final int sequence;
  final String role;
  final String approver;
  final String status;

  ApprovalChainStep({
    required this.sequence,
    required this.role,
    required this.approver,
    required this.status,
  });

  factory ApprovalChainStep.fromJson(Map<String, dynamic> j) => ApprovalChainStep(
        sequence: _toInt(j['sequence']),
        role: _toStr(j['role'], _toStr(j['role_code'])),
        approver: _toStr(j['approver'] is Map ? j['approver']['name'] : j['approver']),
        status: _toStr(j['status'] ?? j['state'], 'pending'),
      );
}

class RequestDetail {
  final int id;
  final String name;
  final String categoryName;
  final String status;
  final String date;
  final String reason;
  final List<RequestValue> values;
  final List<ApprovalChainStep> chain;
  final bool currentStepIsMine;
  final bool currentStepIsOverride;
  final Map<String, dynamic>? loan;
  final Map<String, dynamic> raw;

  RequestDetail({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.status,
    required this.date,
    required this.reason,
    required this.values,
    required this.chain,
    required this.currentStepIsMine,
    required this.currentStepIsOverride,
    required this.loan,
    required this.raw,
  });

  factory RequestDetail.fromJson(Map<String, dynamic> json) {
    // Server may wrap the payload in a "request" key.
    final j = Map<String, dynamic>.from(
        json['request'] is Map ? json['request'] : json);
    final current = j['current_step'] is Map
        ? Map<String, dynamic>.from(j['current_step'])
        : <String, dynamic>{};
    return RequestDetail(
      id: _toInt(j['id'] ?? j['request_id']),
      name: _toStr(j['name'], _toStr(j['display_name'])),
      categoryName: _toStr(j['category'] is Map
          ? j['category']['name']
          : (j['category_name'] ?? j['category'])),
      status: _toStr(j['status'] ?? j['state'], 'new'),
      date: _toStr(j['date'] ?? j['create_date']),
      reason: _toStr(j['reason']),
      values: ((j['values'] ?? []) as List)
          .map((e) => RequestValue.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      chain: ((j['chain'] ?? []) as List)
          .map((e) => ApprovalChainStep.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentStepIsMine: _toBool(current['is_mine']),
      currentStepIsOverride:
          _toBool(current['is_override'] ?? current['override_point']),
      loan: j['loan'] is Map ? Map<String, dynamic>.from(j['loan']) : null,
      raw: j,
    );
  }
}

class LoanInstallment {
  final String date;
  final double amount;
  final bool paid;

  LoanInstallment({required this.date, required this.amount, required this.paid});

  factory LoanInstallment.fromJson(Map<String, dynamic> j) => LoanInstallment(
        date: _toStr(j['date'] ?? j['payment_date']),
        amount: _toDouble(j['amount']),
        paid: _toBool(j['paid'] ?? j['is_paid']),
      );
}

class MyLoan {
  final int id;
  final String name;
  final double amount;
  final double paidAmount;
  final double remainingAmount;
  final String state;
  final List<LoanInstallment> installments;

  MyLoan({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.state,
    required this.installments,
  });

  factory MyLoan.fromJson(Map<String, dynamic> j) => MyLoan(
        id: _toInt(j['id']),
        name: _toStr(j['name'], _toStr(j['display_name'])),
        amount: _toDouble(j['amount'] ?? j['loan_amount']),
        paidAmount: _toDouble(j['paid'] ?? j['paid_amount'] ?? j['total_paid_amount']),
        remainingAmount: _toDouble(
            j['remaining'] ?? j['remaining_amount'] ?? j['balance_amount']),
        state: _toStr(j['state'] ?? j['status']),
        installments: ((j['installments'] ?? j['loan_lines'] ?? []) as List)
            .map((e) => LoanInstallment.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
