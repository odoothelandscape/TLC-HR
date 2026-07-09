import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utility/style/theme.dart';
import '../leave/leave_history_list_screen.dart';
import '../leave/leave_request_screen.dart';
import 'approvals_inbox_screen.dart';
import 'my_requests_screen.dart';
import 'request_sections_screen.dart';
import '../../../app/locale_controller.dart';

/// HR & Admin hub — employee requests plus leave, in one menu.
/// Access is open to everyone by default; set the `hr_admin_access`
/// shared preference to false to lock this menu for a device.
class HrAdminScreen extends StatefulWidget {
  const HrAdminScreen({Key? key}) : super(key: key);

  @override
  State<HrAdminScreen> createState() => _HrAdminScreenState();
}

class _HrAdminScreenState extends State<HrAdminScreen> {
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final pref = await SharedPreferences.getInstance();
    // Default: everyone has access unless the flag was explicitly disabled.
    setState(() => _allowed = pref.getBool('hr_admin_access') ?? true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.hrAdmin),
        backgroundColor: ColorObj.mainColor,
      ),
      body: _allowed == null
          ? const Center(child: CircularProgressIndicator())
          : !_allowed!
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      context.l10n.hrAdminNoAccess,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _MenuCard(
                      icon: Icons.add_circle_outline,
                      title: context.l10n.newRequest,
                      subtitle: context.l10n.newRequestSubtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RequestSectionsScreen())),
                    ),
                    _MenuCard(
                      icon: Icons.assignment_outlined,
                      title: context.l10n.myRequests,
                      subtitle: context.l10n.myRequestsSubtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyRequestsScreen())),
                    ),
                    _MenuCard(
                      icon: Icons.event_available_outlined,
                      title: context.l10n.leaveRequest,
                      subtitle: context.l10n.leaveRequestSubtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LeaveRequestScreen())),
                    ),
                    _MenuCard(
                      icon: Icons.history,
                      title: context.l10n.leaveHistory,
                      subtitle: context.l10n.leaveHistorySubtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LeaveHistoryListScreen())),
                    ),
                    _MenuCard(
                      icon: Icons.pending_actions_outlined,
                      title: context.l10n.approvals,
                      subtitle: context.l10n.approvalsSubtitle,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ApprovalsInboxScreen())),
                    ),
                  ],
                ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ColorObj.mainColor.withOpacity(0.12),
          child: Icon(icon, color: ColorObj.mainColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
