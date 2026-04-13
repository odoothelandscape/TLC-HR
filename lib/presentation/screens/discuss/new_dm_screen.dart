import 'package:flutter/material.dart';
import 'package:talent_hr/data/api/discuss_api.dart';
import 'package:talent_hr/data/models/discuss/channel_model.dart';
import 'package:talent_hr/utility/style/theme.dart';
import 'chat_screen.dart';

class NewDmScreen extends StatefulWidget {
  const NewDmScreen({Key? key}) : super(key: key);

  @override
  State<NewDmScreen> createState() => _NewDmScreenState();
}

class _NewDmScreenState extends State<NewDmScreen> {
  final _api = DiscussAPI();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    final employees = await _api.getEmployees();
    if (mounted) {
      setState(() {
        _employees = employees;
        _filtered = employees;
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _employees
          .where((e) =>
              (e['name'] as String).toLowerCase().contains(q) ||
              (e['department'] as String).toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> _startDm(Map<String, dynamic> emp) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: ColorObj.mainColor)),
    );

    final channelId = await _api.startDm(emp['id']);
    if (!mounted) return;
    Navigator.pop(context); // close loader

    if (channelId != null) {
      final channel = DiscussChannel(
        id: channelId,
        name: emp['name'],
        channelType: 'chat',
        unreadCount: 0,
        lastMessage: '',
        lastMessageDate: '',
        members: [],
        avatarUrl: '',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(channel: channel, baseUrl: '')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start conversation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorObj.mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('New Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employee...',
                prefixIcon: const Icon(Icons.search, color: ColorObj.mainColor),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: ColorObj.mainColor))
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
                    itemBuilder: (_, i) {
                      final emp = _filtered[i];
                      return ListTile(
                        onTap: () => _startDm(emp),
                        leading: CircleAvatar(
                          backgroundColor: ColorObj.mainColor.withOpacity(0.15),
                          child: Text(
                            (emp['name'] as String)[0].toUpperCase(),
                            style: const TextStyle(color: ColorObj.mainColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(emp['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          emp['department'] != '' ? emp['department'] : emp['job_title'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
