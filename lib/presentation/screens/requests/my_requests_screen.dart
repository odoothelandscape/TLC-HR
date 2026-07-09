import 'package:flutter/material.dart';

import '../../../data/api/requests_api.dart';
import '../../../data/models/request/employee_request_models.dart';
import '../../../utility/style/theme.dart';
import 'request_detail_screen.dart';
import 'request_sections_screen.dart';
import 'request_ui_helpers.dart';
import '../../../app/locale_controller.dart';

/// The requester's own requests with status filter and pagination.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  static const _pageSize = 40;
  static const _statuses = <String?>[
    null,
    'pending',
    'approved',
    'refused',
    'cancel'
  ];

  final _api = RequestsAPI();
  final List<MyRequestItem> _items = [];
  String? _status;
  int _total = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) {
        _items.clear();
        _error = null;
      }
    });
    try {
      final page = await _api.getMyRequests(
          status: _status, offset: _items.length, limit: _pageSize);
      setState(() {
        _items.addAll(page.requests);
        _total = page.total;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openNewRequest() async {
    final created = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const RequestSectionsScreen()));
    if (created == true) _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myRequests),
        backgroundColor: ColorObj.mainColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorObj.mainColor,
        onPressed: _openNewRequest,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.statusNew),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _statuses
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s == null ? context.l10n.all : requestStatusLabel(context, s)),
                          selected: _status == s,
                          selectedColor: ColorObj.mainColor.withOpacity(0.15),
                          onSelected: (_) {
                            setState(() => _status = s);
                            _load(reset: true);
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorObj.mainColor),
                onPressed: () => _load(reset: true),
                child: Text(context.l10n.retry)),
          ],
        ),
      );
    }
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return Center(child: Text(context.l10n.noRequestsYet));
    }
    final hasMore = _items.length < _total;
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
        itemCount: _items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _items.length) {
            if (!_loading) _load();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final r = _items[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(r.categoryName.isNotEmpty ? r.categoryName : r.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                [r.name, r.date].where((s) => s.isNotEmpty).join('  ·  '),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: StatusChip(status: r.status),
              onTap: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(requestId: r.id)),
                );
                if (changed == true) _load(reset: true);
              },
            ),
          );
        },
      ),
    );
  }
}
