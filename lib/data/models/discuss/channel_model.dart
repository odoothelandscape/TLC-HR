class DiscussChannel {
  final int id;
  final String name;
  final String channelType; // 'chat' or 'channel'
  final int unreadCount;
  final String lastMessage;
  final String lastMessageDate;
  final List<Map<String, dynamic>> members;
  final String avatarUrl;

  DiscussChannel({
    required this.id,
    required this.name,
    required this.channelType,
    required this.unreadCount,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.members,
    required this.avatarUrl,
  });

  factory DiscussChannel.fromJson(Map<String, dynamic> json) {
    return DiscussChannel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      channelType: json['channel_type'] ?? 'chat',
      unreadCount: json['unread_count'] ?? 0,
      lastMessage: _stripHtml(json['last_message'] ?? ''),
      lastMessageDate: json['last_message_date'] ?? '',
      members: List<Map<String, dynamic>>.from(json['members'] ?? []),
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
