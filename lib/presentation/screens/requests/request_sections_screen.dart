import 'package:flutter/material.dart';

import '../../../data/api/requests_api.dart';
import '../../../data/models/request/employee_request_models.dart';
import '../../../utility/style/theme.dart';
import 'request_form_screen.dart';
import 'request_ui_helpers.dart';
import '../../../app/locale_controller.dart';

/// Sections + request types catalog — entry point to create a new request.
class RequestSectionsScreen extends StatefulWidget {
  const RequestSectionsScreen({Key? key}) : super(key: key);

  @override
  State<RequestSectionsScreen> createState() => _RequestSectionsScreenState();
}

class _RequestSectionsScreenState extends State<RequestSectionsScreen> {
  final _api = RequestsAPI();
  late Future<List<RequestSection>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getSections();
  }

  Future<void> _reload() async {
    setState(() => _future = _api.getSections());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.newRequest),
        backgroundColor: ColorObj.mainColor,
      ),
      body: FutureBuilder<List<RequestSection>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorRetry(message: '${snap.error}', onRetry: _reload);
          }
          final sections = snap.data ?? [];
          if (sections.isEmpty) {
            return Center(child: Text(context.l10n.noRequestTypes));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sections.length,
              itemBuilder: (context, i) {
                final section = sections[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    initiallyExpanded: sections.length == 1,
                    leading: CircleAvatar(
                      backgroundColor: ColorObj.mainColor.withOpacity(0.12),
                      child: Icon(sectionIcon(section.icon),
                          color: ColorObj.mainColor),
                    ),
                    title: Text(section.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(context.l10n.requestTypesCount(section.categories.length),
                        style: const TextStyle(fontSize: 12)),
                    children: section.categories
                        .map((c) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.chevron_right, size: 20),
                              title: Text(c.name),
                              subtitle: c.description.isEmpty
                                  ? null
                                  : Text(c.description,
                                      style: const TextStyle(fontSize: 12)),
                              onTap: () async {
                                final created = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RequestFormScreen(
                                        category: c, sectionName: section.name),
                                  ),
                                );
                                if (created == true && mounted) {
                                  Navigator.pop(context, true);
                                }
                              },
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorObj.mainColor),
                onPressed: onRetry,
                child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
