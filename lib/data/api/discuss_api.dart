import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_hr/data/models/discuss/channel_model.dart';
import 'package:talent_hr/data/models/discuss/message_model.dart';

class DiscussAPI {
  Future<Map<String, String>> _headers() async {
    final pref = await SharedPreferences.getInstance();
    final cookie = pref.getString('header_cookie') ?? '';
    final db = pref.getString('database') ?? '';
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'cookie': cookie,
      'db_name': db,
    };
  }

  Future<String> _url(String path) async {
    final pref = await SharedPreferences.getInstance();
    final base = pref.getString('url') ?? '';
    return '$base$path';
  }

  /// Odoo type='http' endpoints return {"result": YOUR_DATA} directly.
  /// _parse() extracts data['result'] so callers receive YOUR_DATA.
  dynamic _parse(http.Response res) {
    if (res.statusCode != 200) return null;
    try {
      final data = json.decode(res.body);
      return data['result'];
    } catch (_) {
      return null;
    }
  }

  // ── Register FCM token ──────────────────────────────────────
  Future<bool> registerFcmToken(String token) async {
    try {
      final url = Uri.parse(await _url('api/discuss/fcm/register'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({'fcm_token': token}));
      final data = _parse(res);
      // data = {'success': true}
      return data?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── Get channels list ───────────────────────────────────────
  Future<List<DiscussChannel>> getChannels() async {
    try {
      final url = Uri.parse(await _url('api/discuss/channels'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({}));
      final data = _parse(res);
      // data = [...] list directly
      final List list = (data is List ? data : []);
      return list.map((e) => DiscussChannel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ── Get messages ────────────────────────────────────────────
  Future<List<DiscussMessage>> getMessages(int channelId,
      {int sinceId = 0, int limit = 50}) async {
    try {
      final url = Uri.parse(await _url('api/discuss/channel/messages'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({
            'channel_id': channelId,
            'since_id': sinceId,
            'limit': limit,
          }));
      final data = _parse(res);
      // data = [...] list directly
      final List list = (data is List ? data : []);
      return list.map((e) => DiscussMessage.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ── Send text message ───────────────────────────────────────
  Future<bool> sendMessage(int channelId, String body) async {
    try {
      final url = Uri.parse(await _url('api/discuss/channel/send'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({'channel_id': channelId, 'body': body}));
      final data = _parse(res);
      // data = {'success': true, 'message_id': 123}
      return data?['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ── Send file / image ───────────────────────────────────────
  Future<bool> sendFile(int channelId, File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final filename = file.path.split('/').last;
      final mimetype = _getMimeType(filename);

      final url = Uri.parse(await _url('api/discuss/channel/send-file'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({
            'channel_id': channelId,
            'filename': filename,
            'mimetype': mimetype,
            'file_data': base64Data,
          }));
      final data = _parse(res);
      // data = {'success': true, 'message_id': ..., 'attachment_id': ...}
      return data?['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ── Mark channel as read ────────────────────────────────────
  Future<void> markAsRead(int channelId) async {
    try {
      final url = Uri.parse(await _url('api/discuss/channel/read'));
      await http.post(url,
          headers: await _headers(),
          body: json.encode({'channel_id': channelId}));
    } catch (_) {}
  }

  // ── Start DM ────────────────────────────────────────────────
  Future<int?> startDm(int employeeId) async {
    try {
      final url = Uri.parse(await _url('api/discuss/dm/start'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({'employee_id': employeeId}));
      final data = _parse(res);
      // data = {'success': true, 'channel_id': 123}
      if (data?['success'] == true) return data['channel_id'];
    } catch (e) {
      // ignore: silently ignore network/parse errors, return null below
    }
    return null;
  }

  // ── Create group channel ─────────────────────────────────────
  Future<int?> createGroup(String name, List<int> employeeIds) async {
    try {
      final url = Uri.parse(await _url('api/discuss/group/create'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({'name': name, 'employee_ids': employeeIds}));
      final data = _parse(res);
      // data = {'success': true, 'channel_id': 123}
      if (data?['success'] == true) return data['channel_id'];
    } catch (e) {
      // ignore: silently ignore network/parse errors, return null below
    }
    return null;
  }

  // ── Get employees for DM selection ──────────────────────────
  Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      final url = Uri.parse(await _url('api/discuss/employees'));
      final res = await http.post(url,
          headers: await _headers(),
          body: json.encode({}));
      final data = _parse(res); // returns data['result'] from server response
      if (data == null) {
        return [];
      }
      // Server returns {'result': [...]} → _parse returns the list directly
      final List list = data is List ? data : [];
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  String _getMimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }
}
