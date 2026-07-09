import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/api/requests_api.dart';
import '../../../data/models/request/employee_request_models.dart';
import '../../../utility/style/theme.dart';
import 'request_detail_screen.dart';
import '../../../app/locale_controller.dart';

/// Renders the dynamic create-request form from /api/requests/form.
class RequestFormScreen extends StatefulWidget {
  final RequestCategory category;
  final String sectionName;

  const RequestFormScreen(
      {Key? key, required this.category, this.sectionName = ''})
      : super(key: key);

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _api = RequestsAPI();
  final _formKey = GlobalKey<FormState>();

  RequestFormSchema? _schema;
  String? _loadError;
  bool _submitting = false;

  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _roleChoices = {};
  final TextEditingController _reasonController = TextEditingController();
  int? _relatedLoanId;
  final List<Map<String, String>> _extraAttachments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _schema = null;
      _loadError = null;
    });
    try {
      final schema = await _api.getForm(widget.category.id);
      for (final f in schema.fields) {
        if (f.type == 'char' ||
            f.type == 'text' ||
            f.type == 'number' ||
            f.type == 'employee') {
          _controllers[f.code] = TextEditingController();
        }
      }
      setState(() => _schema = schema);
    } catch (e) {
      setState(() => _loadError = '$e');
    }
  }

  bool get _needsRelatedLoan =>
      widget.category.postApprovalAction == 'link_loan';

  Future<void> _pickAttachment(String? fieldCode) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    final bytes = await File(file.path!).readAsBytes();
    final att = {'name': file.name, 'data': base64Encode(bytes)};
    setState(() {
      if (fieldCode != null) {
        _values[fieldCode] = att;
      } else {
        _extraAttachments.add(Map<String, String>.from(att));
      }
    });
  }

  Future<void> _submit() async {
    final schema = _schema;
    if (schema == null) return;
    if (!_formKey.currentState!.validate()) return;

    // Collect text controller values.
    for (final f in schema.fields) {
      final c = _controllers[f.code];
      if (c == null) continue;
      final text = c.text.trim();
      if (text.isEmpty) continue;
      if (f.type == 'number') {
        _values[f.code] = num.tryParse(text) ?? text;
      } else if (f.type == 'employee') {
        _values[f.code] = int.tryParse(text) ?? text;
      } else {
        _values[f.code] = text;
      }
    }

    // Required checks for non-text fields.
    for (final f in schema.fields) {
      if (!f.required) continue;
      final v = _values[f.code];
      if (v == null || (v is String && v.isEmpty)) {
        Fluttertoast.showToast(msg: context.l10n.fieldRequired(f.label));
        return;
      }
    }
    if (_needsRelatedLoan && _relatedLoanId == null) {
      Fluttertoast.showToast(msg: context.l10n.pleaseSelectRelatedLoan);
      return;
    }

    setState(() => _submitting = true);
    try {
      final detail = await _api.createRequest(
        categoryId: widget.category.id,
        values: _values,
        reason: _reasonController.text.trim(),
        roleChoices: _roleChoices.isEmpty ? null : _roleChoices,
        relatedLoanId: _relatedLoanId,
        attachments: _extraAttachments.isEmpty ? null : _extraAttachments,
      );
      if (!mounted) return;
      Fluttertoast.showToast(msg: context.l10n.requestSubmitted);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => RequestDetailScreen(
                requestId: detail.id, initialDetail: detail)),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name, overflow: TextOverflow.ellipsis),
        backgroundColor: ColorObj.mainColor,
      ),
      body: _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorObj.mainColor),
                        onPressed: _load,
                        child: Text(context.l10n.retry)),
                  ],
                ),
              ),
            )
          : _schema == null
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(_schema!),
    );
  }

  Widget _buildForm(RequestFormSchema schema) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (schema.chainPreview.isNotEmpty) ...[
            Text(context.l10n.approvalChain,
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ChainPreview(steps: schema.chainPreview),
            const Divider(height: 24),
          ],
          for (final f in schema.fields) ...[
            _buildField(f),
            const SizedBox(height: 14),
          ],
          if (_needsRelatedLoan) ...[
            _buildRelatedLoan(schema),
            const SizedBox(height: 14),
          ],
          for (final rc in schema.roleChoices) ...[
            _buildRoleChoice(rc),
            const SizedBox(height: 14),
          ],
          TextFormField(
            controller: _reasonController,
            maxLines: 2,
            decoration: _dec(context.l10n.noteOptional),
          ),
          const SizedBox(height: 14),
          _buildExtraAttachments(),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorObj.mainColor),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(context.l10n.submitRequest),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, {String? hint, String? help}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: (help != null && help.isNotEmpty) ? help : null,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  String _label(RequestField f) => f.required ? '${f.label} *' : f.label;

  Widget _buildField(RequestField f) {
    switch (f.type) {
      case 'text':
        return TextFormField(
          controller: _controllers[f.code],
          maxLines: 3,
          decoration: _dec(_label(f), hint: f.placeholder, help: f.help),
          validator: (v) => f.required && (v == null || v.trim().isEmpty)
              ? context.l10n.fieldRequired(f.label)
              : null,
        );
      case 'number':
        return TextFormField(
          controller: _controllers[f.code],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _dec(_label(f), hint: f.placeholder, help: f.help),
          validator: (v) {
            if (f.required && (v == null || v.trim().isEmpty)) {
              return context.l10n.fieldRequired(f.label);
            }
            if (v != null && v.trim().isNotEmpty && num.tryParse(v.trim()) == null) {
              return context.l10n.enterValidNumber;
            }
            return null;
          },
        );
      case 'employee':
        if (f.options.isNotEmpty) return _buildSelection(f);
        return TextFormField(
          controller: _controllers[f.code],
          keyboardType: TextInputType.number,
          decoration:
              _dec(_label(f), hint: f.placeholder.isEmpty ? context.l10n.employeeId : f.placeholder, help: f.help),
          validator: (v) => f.required && (v == null || v.trim().isEmpty)
              ? context.l10n.fieldRequired(f.label)
              : null,
        );
      case 'date':
      case 'datetime':
        return _DatePickerField(
          label: _label(f),
          help: f.help,
          withTime: f.type == 'datetime',
          value: _values[f.code]?.toString(),
          onChanged: (v) => setState(() => _values[f.code] = v),
        );
      case 'boolean':
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(f.label),
          subtitle: f.help.isEmpty ? null : Text(f.help),
          value: _values[f.code] == true,
          activeColor: ColorObj.mainColor,
          onChanged: (v) => setState(() => _values[f.code] = v),
        );
      case 'selection':
        return _buildSelection(f);
      case 'attachment':
        final v = _values[f.code];
        return _AttachmentTile(
          label: _label(f),
          fileName: v is Map ? v['name']?.toString() : null,
          onPick: () => _pickAttachment(f.code),
          onClear: v == null
              ? null
              : () => setState(() => _values.remove(f.code)),
        );
      case 'char':
      default:
        return TextFormField(
          controller: _controllers[f.code],
          decoration: _dec(_label(f), hint: f.placeholder, help: f.help),
          validator: (v) => f.required && (v == null || v.trim().isEmpty)
              ? context.l10n.fieldRequired(f.label)
              : null,
        );
    }
  }

  Widget _buildSelection(RequestField f) {
    return DropdownButtonFormField<dynamic>(
      value: _values[f.code],
      isExpanded: true,
      decoration: _dec(_label(f), help: f.help),
      items: f.options
          .map((o) => DropdownMenuItem<dynamic>(
              value: o.sendValue, child: Text(o.label)))
          .toList(),
      onChanged: (v) => setState(() => _values[f.code] = v),
      validator: (v) =>
          f.required && v == null ? context.l10n.fieldRequired(f.label) : null,
    );
  }

  Widget _buildRelatedLoan(RequestFormSchema schema) {
    if (schema.runningLoans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
            context.l10n.noActiveLoans),
      );
    }
    return DropdownButtonFormField<int>(
      value: _relatedLoanId,
      isExpanded: true,
      decoration: _dec(context.l10n.relatedLoanRequired),
      items: schema.runningLoans
          .map((l) => DropdownMenuItem(
                value: l.id,
                child: Text(l.remaining > 0
                    ? context.l10n
                        .loanWithRemaining(l.name, l.remaining.toStringAsFixed(0))
                    : l.name),
              ))
          .toList(),
      onChanged: (v) => setState(() => _relatedLoanId = v),
    );
  }

  Widget _buildRoleChoice(RoleChoice rc) {
    return DropdownButtonFormField<int>(
      value: _roleChoices[rc.roleCode],
      isExpanded: true,
      decoration: _dec(context.l10n.approverFor(rc.role)),
      items: rc.candidates
          .map((c) => DropdownMenuItem(value: c.userId, child: Text(c.name)))
          .toList(),
      onChanged: (v) => setState(() {
        if (v == null) {
          _roleChoices.remove(rc.roleCode);
        } else {
          _roleChoices[rc.roleCode] = v;
        }
      }),
    );
  }

  Widget _buildExtraAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(context.l10n.attachments,
                    style: TextStyle(fontWeight: FontWeight.bold))),
            TextButton.icon(
              onPressed: () => _pickAttachment(null),
              icon: const Icon(Icons.attach_file, size: 18),
              label: Text(context.l10n.add),
            ),
          ],
        ),
        for (var i = 0; i < _extraAttachments.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: Text(_extraAttachments[i]['name'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => setState(() => _extraAttachments.removeAt(i)),
            ),
          ),
      ],
    );
  }
}

class _ChainPreview extends StatelessWidget {
  final List<ChainStep> steps;
  const _ChainPreview({required this.steps});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Chip(
              backgroundColor: ColorObj.mainColor.withOpacity(0.08),
              label: Text(steps[i].role, style: const TextStyle(fontSize: 12)),
              avatar: CircleAvatar(
                backgroundColor: ColorObj.mainColor,
                child: Text('${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
            if (i < steps.length - 1)
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
          ],
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String help;
  final bool withTime;
  final String? value;
  final ValueChanged<String> onChanged;

  const _DatePickerField({
    required this.label,
    required this.help,
    required this.withTime,
    required this.value,
    required this.onChanged,
  });

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null) return;
    if (!withTime) {
      onChanged('${date.year}-${_two(date.month)}-${_two(date.day)}');
      return;
    }
    // Safe: we bail out when the context is unmounted. The 3.7-era analyzer
    // doesn't understand context.mounted guards, so silence the lint here.
    // ignore: use_build_context_synchronously
    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    final t = time ?? TimeOfDay.now();
    onChanged(
        '${date.year}-${_two(date.month)}-${_two(date.day)} ${_two(t.hour)}:${_two(t.minute)}:00');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: help.isNotEmpty ? help : null,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(value ?? context.l10n.selectEllipsis,
            style: TextStyle(
                color: value == null ? Colors.grey : Colors.black87)),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final String label;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _AttachmentTile({
    required this.label,
    required this.fileName,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(fileName ?? context.l10n.noFileSelected,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: fileName == null ? Colors.grey : Colors.black87)),
          ),
          if (onClear != null)
            IconButton(
                icon: const Icon(Icons.close, size: 18), onPressed: onClear),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.attach_file, size: 18),
            label: Text(context.l10n.pick),
          ),
        ],
      ),
    );
  }
}
