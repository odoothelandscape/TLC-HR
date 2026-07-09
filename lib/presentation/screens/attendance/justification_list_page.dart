import 'package:flutter/material.dart';

import '../../../data/api/attendance_justification_api.dart';
import '../../../data/models/justification/justification.dart';
import '../../widgets/no_data.dart';
import 'justification_dialog.dart';
import 'package:talent_hr/app/locale_controller.dart';

/// context.l10n.justificationRequests tab inside the attendance screen.
class JustificationListPage extends StatefulWidget {
  const JustificationListPage({Key? key}) : super(key: key);

  @override
  State<JustificationListPage> createState() => _JustificationListPageState();
}

class _JustificationListPageState extends State<JustificationListPage> {
  final api = AttendanceJustificationAPI();
  List<Justification> records = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _load();
    // refreshed after new submissions and FCM decision pushes
    justificationRefreshTick.addListener(_load);
  }

  @override
  void dispose() {
    justificationRefreshTick.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = '';
    });
    final result = await api.getJustifications();
    if (!mounted) return;
    setState(() {
      loading = false;
      if (result['success'] == true) {
        records = result['records'] as List<Justification>;
      } else {
        error = result['message'].toString();
      }
    });
  }

  Color _stateColor(String state) {
    switch (state) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'newJustification',
        onPressed: () async {
          await showJustificationDialog(context,
              type: 'missed_checkin', allowTypeChange: true);
        },
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newRequest),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: error.isNotEmpty
                  ? ListView(children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Could not load requests:\n$error',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700])),
                      )
                    ])
                  : records.isEmpty
                      ? ListView(children: [
                          SizedBox(
                              height: 300,
                              child: Center(child: noDataWidget(context)))
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: records.length,
                          itemBuilder: (context, i) {
                            final r = records[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            justificationTypeLabels(context)[
                                                    r.justificationType] ??
                                                r.justificationType,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _stateColor(r.state)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            r.state.toUpperCase(),
                                            style: TextStyle(
                                                color: _stateColor(r.state),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${r.date}   •   Submitted: ${r.submittedOn}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(r.reason),
                                    if (r.escalatedToManager)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6),
                                        child: Row(children: [
                                          Icon(Icons.arrow_upward,
                                              size: 14,
                                              color: Colors.orange[800]),
                                          const SizedBox(width: 4),
                                          Text(context.l10n.escalatedToManager,
                                              style: TextStyle(
                                                  color: Colors.orange[800],
                                                  fontSize: 12)),
                                        ]),
                                      ),
                                    if (r.reviewNote.isNotEmpty)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(8),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                            'Review note: ${r.reviewNote}',
                                            style: const TextStyle(
                                                fontSize: 13)),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
    );
  }
}
