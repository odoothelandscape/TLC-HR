import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_hr/data/api/discuss_api.dart';
import 'package:talent_hr/data/models/discuss/channel_model.dart';
import 'package:talent_hr/utility/style/theme.dart';
import 'chat_screen.dart';
import 'new_dm_screen.dart';
import 'new_group_screen.dart';
import 'package:talent_hr/app/locale_controller.dart';

class DiscussScreen extends StatefulWidget {
  const DiscussScreen({Key? key}) : super(key: key);

  @override
  State<DiscussScreen> createState() => _DiscussScreenState();
}

class _DiscussScreenState extends State<DiscussScreen> {
  final _api = DiscussAPI();
  List<DiscussChannel> _channels = [];
  bool _loading = true;
  Timer? _refreshTimer;
  String _baseUrl = '';

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
    _loadChannels();
    // Auto-refresh every 15 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadChannels(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBaseUrl() async {
    final pref = await SharedPreferences.getInstance();
    setState(() => _baseUrl = pref.getString('url') ?? '');
  }

  Future<void> _loadChannels({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    final channels = await _api.getChannels();
    if (mounted) {
      setState(() {
        _channels = channels;
        _loading = false;
      });
    }
  }

  void _openChat(DiscussChannel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(channel: channel, baseUrl: _baseUrl),
      ),
    ).then((_) => _loadChannels(silent: true));
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorObj.mainColor,
        title: Text(context.l10n.discuss, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadChannels,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'group',
            backgroundColor: ColorObj.mainColor,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewGroupScreen()),
            ).then((_) => _loadChannels()),
            tooltip: context.l10n.newGroup,
            child: const Icon(Icons.group_add, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'dm',
            backgroundColor: ColorObj.mainColor,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewDmScreen()),
            ).then((_) => _loadChannels()),
            tooltip: context.l10n.newMessage,
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: ColorObj.mainColor))
          : _channels.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: ColorObj.mainColor,
                  onRefresh: _loadChannels,
                  child: ListView.separated(
                    itemCount: _channels.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) => _buildChannelTile(_channels[i]),
                  ),
                ),
    );
  }

  Widget _buildChannelTile(DiscussChannel ch) {
    final isGroup = ch.channelType == 'channel';
    return ListTile(
      onTap: () => _openChat(ch),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: ColorObj.mainColor.withOpacity(0.15),
        backgroundImage: _baseUrl.isNotEmpty && ch.avatarUrl.isNotEmpty
            ? NetworkImage('$_baseUrl${ch.avatarUrl.startsWith('/') ? ch.avatarUrl.substring(1) : ch.avatarUrl}')
            : null,
        child: (_baseUrl.isEmpty || ch.avatarUrl.isEmpty)
            ? Icon(isGroup ? Icons.group : Icons.person, color: ColorObj.mainColor)
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              ch.name,
              style: TextStyle(
                fontWeight: ch.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatDate(ch.lastMessageDate),
            style: TextStyle(
              fontSize: 12,
              color: ch.unreadCount > 0 ? ColorObj.mainColor : Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              ch.lastMessage.isEmpty ? context.l10n.noMessagesYet : ch.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ch.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                fontWeight: ch.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          if (ch.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: ColorObj.mainColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ch.unreadCount > 99 ? '99+' : '${ch.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(context.l10n.noConversationsYet, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 8),
          Text(context.l10n.tapChatToStart, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}
