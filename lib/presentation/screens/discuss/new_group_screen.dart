import 'package:flutter/material.dart';
import 'package:talent_hr/data/api/discuss_api.dart';
import 'package:talent_hr/data/models/discuss/channel_model.dart';
import 'package:talent_hr/utility/style/theme.dart';
import 'chat_screen.dart';
import 'package:talent_hr/app/locale_controller.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({Key? key}) : super(key: key);

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _api = DiscussAPI();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filtered = [];
  final Set<int> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          .where((e) => (e['name'] as String).toLowerCase().contains(q))
          .toList();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterGroupName)),
      );
      return;
    }
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseSelectOneMember)),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: ColorObj.mainColor)),
    );

    final channelId = await _api.createGroup(name, _selectedIds.toList());
    if (!mounted) return;
    Navigator.pop(context);

    if (channelId != null) {
      final channel = DiscussChannel(
        id: channelId,
        name: name,
        channelType: 'channel',
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
        SnackBar(content: Text(context.l10n.failedToCreateGroup)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEmployees = _employees.where((e) => _selectedIds.contains(e['id'])).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorObj.mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(context.l10n.newGroup, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: Text(context.l10n.create, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group name input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: context.l10n.groupNameHint,
                prefixIcon: const Icon(Icons.group, color: ColorObj.mainColor),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Selected members chips
          if (selectedEmployees.isNotEmpty)
            Container(
              height: 50,
              color: Colors.grey[50],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: selectedEmployees.length,
                itemBuilder: (_, i) {
                  final emp = selectedEmployees[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text(emp['name'], style: const TextStyle(fontSize: 12)),
                      onDeleted: () => _toggleSelect(emp['id']),
                      backgroundColor: ColorObj.mainColor.withOpacity(0.1),
                      deleteIconColor: ColorObj.mainColor,
                    ),
                  );
                },
              ),
            ),

          // Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.searchEmployee,
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

          // Employees list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: ColorObj.mainColor))
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 60),
                    itemBuilder: (_, i) {
                      final emp = _filtered[i];
                      final selected = _selectedIds.contains(emp['id']);
                      return ListTile(
                        onTap: () => _toggleSelect(emp['id']),
                        leading: CircleAvatar(
                          backgroundColor: selected
                              ? ColorObj.mainColor
                              : ColorObj.mainColor.withOpacity(0.15),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : Text(
                                  (emp['name'] as String)[0].toUpperCase(),
                                  style: const TextStyle(color: ColorObj.mainColor, fontWeight: FontWeight.bold),
                                ),
                        ),
                        title: Text(emp['name'],
                            style: TextStyle(
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                        subtitle: Text(emp['department'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: selected
                            ? const Icon(Icons.check_circle, color: ColorObj.mainColor)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
