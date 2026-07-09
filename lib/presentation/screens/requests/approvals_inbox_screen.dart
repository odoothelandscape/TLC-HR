import 'package:flutter/material.dart';

import '../../../data/api/requests_api.dart';
import '../../../data/models/request/employee_request_models.dart';
import '../../../utility/style/theme.dart';
import 'request_detail_screen.dart';
import 'request_ui_helpers.dart';
import '../../../app/locale_controller.dart';

/// Requests waiting for the logged-in user's approval.
class ApprovalsInboxScreen extends StatefulWidget {
  const ApprovalsInboxScreen({Key? key}) : super(key: key);

  @override
  State<ApprovalsInboxScreen> createState() => _ApprovalsInboxScreenState();
}

class _ApprovalsInboxScreenState extends State<ApprovalsInboxScreen> {
  final _api = RequestsAPI();
  List<MyRequestItem>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final items = await _api.getPendingApprovals();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.approvals),
        backgroundColor: ColorObj.mainColor,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorObj.mainColor),
                      onPressed: _load,
                      child: Text(context.l10n.retry)),
                ],
              ),
            )
          : _items == null
              ? const Center(child: CircularProgressIndicator())
              : _items!.isEmpty
                  ? Center(child: Text(context.l10n.nothingWaitingApproval))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _items!.length,
                        itemBuilder: (context, i) {
                          final r = _items![i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    ColorObj.mainColor.withOpacity(0.12),
                                child: const Icon(Icons.pending_actions,
                                    color: ColorObj.mainColor),
                              ),
                              title: Text(
                                  r.categoryName.isNotEmpty
                                      ? r.categoryName
                                      : r.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                [r.name, r.date]
                                    .where((s) => s.isNotEmpty)
                                    .join('  ·  '),
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: StatusChip(status: r.status),
                              onTap: () async {
                                final changed = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RequestDetailScreen(
                                          requestId: r.id)),
                                );
                                if (changed == true) _load();
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
