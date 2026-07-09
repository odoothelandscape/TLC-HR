import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/api/requests_api.dart';
import '../../../data/models/request/employee_request_models.dart';
import '../../../utility/style/theme.dart';
import 'request_ui_helpers.dart';
import '../../../app/locale_controller.dart';

/// Full request detail: values, approval chain, and actions
/// (approve / refuse for the current approver, cancel for the owner).
class RequestDetailScreen extends StatefulWidget {
  final int requestId;
  final RequestDetail? initialDetail;

  const RequestDetailScreen(
      {Key? key, required this.requestId, this.initialDetail})
      : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _api = RequestsAPI();
  RequestDetail? _detail;
  String? _error;
  bool _busy = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _detail = widget.initialDetail;
    // Opened right after creation -> callers should refresh their lists.
    _changed = widget.initialDetail != null;
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _api.getDetail(widget.requestId);
      if (mounted) setState(() => _detail = d);
    } catch (e) {
      if (mounted && _detail == null) setState(() => _error = '$e');
    }
  }

  Future<String?> _askText(String title, String hint) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.back)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ColorObj.mainColor),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(title),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _run(Future<void> Function() action, String successMsg) async {
    setState(() => _busy = true);
    try {
      await action();
      _changed = true;
      Fluttertoast.showToast(msg: successMsg);
      await _load();
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _approve({bool override = false}) async {
    final comment = await _askText(override ? context.l10n.overrideLabel : context.l10n.approve,
        context.l10n.commentOptional);
    if (comment == null) return;
    await _run(
        () => _api.approve(widget.requestId,
            override: override, comment: comment),
        override ? context.l10n.requestOverridden : context.l10n.requestApproved);
  }

  Future<void> _refuse() async {
    final reason = await _askText(context.l10n.refuse, context.l10n.reasonOptional);
    if (reason == null) return;
    await _run(() => _api.refuse(widget.requestId, reason: reason),
        context.l10n.requestRefused);
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.cancelRequestQ),
        content: Text(context.l10n.cancelRequestBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.no)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.yesCancel),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => _api.cancel(widget.requestId), context.l10n.requestCancelled);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_detail?.name.isNotEmpty == true
              ? _detail!.name
              : context.l10n.requestNumber('${widget.requestId}')),
          backgroundColor: ColorObj.mainColor,
        ),
        body: _error != null
            ? Center(child: Text(_error!))
            : _detail == null
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(_detail!),
      ),
    );
  }

  Widget _buildBody(RequestDetail d) {
    final isOpen = d.status == 'new' || d.status == 'pending';
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.categoryName.isNotEmpty ? d.categoryName : d.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      StatusChip(status: d.status),
                    ],
                  ),
                  if (d.date.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(d.date,
                          style: const TextStyle(
                              fontSize: 12, color: ColorObj.secondaryColor)),
                    ),
                  if (d.reason.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(d.reason),
                    ),
                ],
              ),
            ),
          ),
          if (d.values.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(context.l10n.details,
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Card(
              child: Column(
                children: d.values
                    .map((v) => ListTile(
                          dense: true,
                          title: Text(v.label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorObj.secondaryColor)),
                          subtitle: Text(
                            v.displayValue,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          if (d.chain.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(context.l10n.approvalChain,
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Card(
              child: Column(
                children: d.chain
                    .map((s) => ListTile(
                          dense: true,
                          leading: Icon(
                            s.status == 'approved'
                                ? Icons.check_circle
                                : s.status == 'refused'
                                    ? Icons.cancel
                                    : Icons.radio_button_unchecked,
                            color: requestStatusColor(s.status),
                          ),
                          title: Text(s.role),
                          subtitle:
                              s.approver.isEmpty ? null : Text(s.approver),
                          trailing: StatusChip(status: s.status),
                        ))
                    .toList(),
              ),
            ),
          ],
          if (d.loan != null) ...[
            const SizedBox(height: 12),
            Card(
              color: ColorObj.mainColor.withOpacity(0.06),
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined,
                    color: ColorObj.mainColor),
                title: Text(context.l10n.linkedLoan),
                subtitle: Text(d.loan!['name']?.toString() ??
                    context.l10n.loanNumber('${d.loan!['id'] ?? ''}')),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (isOpen && d.currentStepIsMine) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorObj.successColor),
                    onPressed: _busy ? null : () => _approve(),
                    icon: const Icon(Icons.check),
                    label: Text(context.l10n.approve),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _busy ? null : _refuse,
                    icon: const Icon(Icons.close),
                    label: Text(context.l10n.refuse),
                  ),
                ),
              ],
            ),
            if (d.currentStepIsOverride)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _approve(override: true),
                  icon: const Icon(Icons.bolt),
                  label: Text(context.l10n.overrideAndApprove),
                ),
              ),
          ],
          if (isOpen)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: _busy ? null : _cancel,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(context.l10n.cancelMyRequest,
                    style: TextStyle(color: Colors.red)),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
