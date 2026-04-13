class DiscussMessage {
  final int id;
  final int authorId;
  final String authorName;
  final bool isMe;
  final String body;
  final String date;
  final List<MessageAttachment> attachments;

  DiscussMessage({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.isMe,
    required this.body,
    required this.date,
    required this.attachments,
  });

  factory DiscussMessage.fromJson(Map<String, dynamic> json) {
    return DiscussMessage(
      id: json['id'] ?? 0,
      authorId: json['author_id'] ?? 0,
      authorName: json['author_name'] ?? '',
      isMe: json['is_me'] ?? false,
      body: _stripHtml(json['body'] ?? ''),
      date: json['date'] ?? '',
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => MessageAttachment.fromJson(a))
          .toList(),
    );
  }

  bool get hasAttachment => attachments.isNotEmpty;

  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}

class MessageAttachment {
  final int id;
  final String name;
  final String mimetype;
  final String url;

  MessageAttachment({
    required this.id,
    required this.name,
    required this.mimetype,
    required this.url,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mimetype: json['mimetype'] ?? '',
      url: json['url'] ?? '',
    );
  }

  bool get isImage =>
      mimetype.startsWith('image/');
}
