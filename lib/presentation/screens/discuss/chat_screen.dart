import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_hr/data/api/discuss_api.dart';
import 'package:talent_hr/data/models/discuss/channel_model.dart';
import 'package:talent_hr/data/models/discuss/message_model.dart';
import 'package:talent_hr/utility/style/theme.dart';
import 'package:talent_hr/app/locale_controller.dart';

class ChatScreen extends StatefulWidget {
  final DiscussChannel channel;
  final String baseUrl;

  const ChatScreen({Key? key, required this.channel, required this.baseUrl}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _api = DiscussAPI();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  List<DiscussMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  Timer? _pollTimer;
  int _lastMessageId = 0;
  String _cookie = '';

  @override
  void initState() {
    super.initState();
    _initCookie(); // loads cookie → then messages → then starts poll timer
  }

  Future<void> _initCookie() async {
    final pref = await SharedPreferences.getInstance();
    _cookie = pref.getString('header_cookie') ?? '';
    // Load messages AFTER cookie is ready so Image.network has the header
    await _loadMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    final msgs = await _api.getMessages(widget.channel.id, limit: 50);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _loading = false;
        if (msgs.isNotEmpty) _lastMessageId = msgs.last.id;
      });
      _scrollToBottom();
    }
    await _api.markAsRead(widget.channel.id);
  }

  Future<void> _poll() async {
    if (!mounted) return;
    final newMsgs = await _api.getMessages(
      widget.channel.id,
      sinceId: _lastMessageId,
      limit: 20,
    );
    if (mounted && newMsgs.isNotEmpty) {
      setState(() {
        _messages.addAll(newMsgs);
        _lastMessageId = newMsgs.last.id;
      });
      _scrollToBottom();
      await _api.markAsRead(widget.channel.id);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    final ok = await _api.sendMessage(widget.channel.id, text);
    if (ok) {
      await _poll();
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _sendImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return;

      setState(() => _sending = true);
      final file = File(picked.path);
      final ok = await _api.sendFile(widget.channel.id, file);
      if (ok) {
        await _poll();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.failedToSendImage)),
          );
        }
      }
      if (mounted) setState(() => _sending = false);
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _sendCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return;

      setState(() => _sending = true);
      final file = File(picked.path);
      final ok = await _api.sendFile(widget.channel.id, file);
      if (ok) {
        await _poll();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.failedToSendPhoto)),
          );
        }
      }
      if (mounted) setState(() => _sending = false);
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: ColorObj.mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.channel.name,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.channel.channelType == 'channel'
                  ? '${widget.channel.members.length} members'
                  : context.l10n.directMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: ColorObj.mainColor))
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet.\nSay hello! 👋', textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _buildMessage(_messages[i]),
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessage(DiscussMessage msg) {
    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: ColorObj.mainColor.withOpacity(0.2),
              child: Text(msg.authorName.isNotEmpty ? msg.authorName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 12, color: ColorObj.mainColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(msg.authorName,
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                ),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
                padding: msg.hasAttachment && msg.attachments.first.isImage
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? ColorObj.mainColor : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3, offset: const Offset(0, 1))],
                ),
                child: _buildMessageContent(msg, isMe),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(msg.date),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildMessageContent(DiscussMessage msg, bool isMe) {
    if (msg.hasAttachment) {
      final att = msg.attachments.first;
      if (att.isImage) {
        final rawPath = att.url.startsWith('/') ? att.url.substring(1) : att.url;
        final base = widget.baseUrl.endsWith('/')
            ? widget.baseUrl.substring(0, widget.baseUrl.length - 1)
            : widget.baseUrl;
        final imageUrl = '$base/$rawPath';
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            headers: _cookie.isNotEmpty ? {'cookie': _cookie} : {},
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                      color: ColorObj.mainColor,
                    )),
                  ),
            errorBuilder: (_, __, ___) => Container(
              width: 200,
              height: 120,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  SizedBox(height: 4),
                  Text(context.l10n.imageUnavailable, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_file, size: 16, color: isMe ? Colors.white70 : Colors.grey),
            const SizedBox(width: 6),
            Flexible(
              child: Text(att.name,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        );
      }
    }
    return Text(
      msg.body,
      style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 8, right: 8, top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: ColorObj.mainColor),
            onPressed: _sending ? null : _sendImage,
            tooltip: context.l10n.sendImage,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: ColorObj.mainColor),
            onPressed: _sending ? null : _sendCamera,
            tooltip: context.l10n.camera,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.writeAMessage,
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 6),
          _sending
              ? const SizedBox(
                  width: 40, height: 40,
                  child: CircularProgressIndicator(color: ColorObj.mainColor, strokeWidth: 2))
              : GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42, height: 42,
                    decoration: const BoxDecoration(color: ColorObj.mainColor, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
        ],
      ),
    );
  }

  String _formatTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
