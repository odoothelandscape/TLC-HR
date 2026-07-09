import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../data/api/attendance_justification_api.dart';
import 'package:talent_hr/app/locale_controller.dart';

Map<String, String> justificationTypeLabels(BuildContext context) => {
      'missed_checkin': context.l10n.missedCheckIn,
      'missed_checkout': context.l10n.missedCheckOut,
      'auto_checkout': context.l10n.autoCheckout,
      'early_leave': context.l10n.earlyLeave,
      'outside_location': context.l10n.outsideLocation,
    };

/// Shows the justification form with [type] pre-selected.
/// Returns true when a request was submitted successfully.
/// [optional] relaxes the dialog (barrier dismiss + context.l10n.skip button) for the
/// post check-in/out prompts where writing a note is not mandatory.
Future<bool?> showJustificationDialog(
  BuildContext context, {
  required String type,
  int? attendanceId,
  String? date,
  bool allowTypeChange = false,
  bool optional = false,
}) {
  final reasonController = TextEditingController();
  String selectedType = type;
  final api = AttendanceJustificationAPI();

  return showDialog<bool>(
    context: context,
    barrierDismissible: optional,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.attendanceJustification,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (allowTypeChange)
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: context.l10n.type),
                  items: justificationTypeLabels(context).entries
                      .map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v ?? selectedType),
                )
              else
                Chip(
                  label: Text(
                      justificationTypeLabels(context)[selectedType] ?? selectedType),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: context.l10n.reasonRequired2,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(optional ? context.l10n.skip : context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(context.l10n.reasonIsRequired)));
                return;
              }
              EasyLoading.show(status: context.l10n.submitting);
              final result = await api.createJustification(
                type: selectedType,
                reason: reason,
                attendanceId: attendanceId,
                date: date,
              );
              EasyLoading.dismiss();
              if (!ctx.mounted) return;
              if (result['success'] == true) {
                justificationRefreshTick.value++;
                Navigator.pop(ctx, true);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Failed: ${result['message']}')));
              }
            },
            child: Text(context.l10n.submit),
          ),
        ],
      ),
    ),
  );
}
