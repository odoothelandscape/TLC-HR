import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/justification/justification.dart';

/// Bumped whenever a justification is created locally or its state changes
/// via FCM — the justification list listens to this to auto-refresh.
final ValueNotifier<int> justificationRefreshTick = ValueNotifier<int>(0);

class AttendanceJustificationAPI {
  Future<Map<String, String?>> _headers() async {
    final pref = await SharedPreferences.getInstance();
    return {
      'url': pref.getString('url'),
      'cookie': pref.getString('header_cookie'),
      'db': pref.getString('database'),
    };
  }

  /// POST /api/attendance/justification — registers immediately as pending.
  /// employee_id/attendance_id/date are optional (backend infers employee
  /// from the session, date defaults to today). reason is mandatory.
  Future<Map<String, dynamic>> createJustification({
    required String type,
    required String reason,
    int? employeeId,
    int? attendanceId,
    String? date,
  }) async {
    final h = await _headers();
    final param = <String, dynamic>{
      'justification_type': type,
      'reason': reason,
      if (employeeId != null && employeeId > 0) 'employee_id': employeeId,
      if (attendanceId != null && attendanceId > 0)
        'attendance_id': attendanceId,
      if (date != null && date.isNotEmpty) 'date': date,
    };

    try {
      final url = Uri.parse('${h['url']}' 'api/attendance/justification');
      final res = await http.post(url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'cookie': h['cookie'] ?? '',
            'db_name': h['db'] ?? '',
          },
          body: json.encode(param));
      if (res.statusCode != 200) {
        return {'success': false, 'message': 'HTTP ${res.statusCode}'};
      }
      final decoded = json.decode(res.body);
      final root = (decoded is Map && decoded['result'] != null)
          ? decoded['result']
          : decoded;
      if (root is Map && root['success'] == true) {
        return {
          'success': true,
          'justification_id': root['justification_id'],
          'state': root['state'],
        };
      }
      final message = root is Map
          ? (root['message'] ?? root['error'] ?? 'Unexpected response')
          : 'Unexpected response';
      return {'success': false, 'message': message.toString()};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /api/attendance/justification/status?state=&limit=&offset=
  Future<Map<String, dynamic>> getJustifications(
      {String? state, int limit = 50, int offset = 0}) async {
    final h = await _headers();
    try {
      var uri = Uri.parse(
          '${h['url']}' 'api/attendance/justification/status');
      uri = uri.replace(queryParameters: {
        if (state != null && state.isNotEmpty) 'state': state,
        'limit': limit.toString(),
        'offset': offset.toString(),
      });
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
        'cookie': h['cookie'] ?? '',
        'db_name': h['db'] ?? '',
      });
      if (res.statusCode != 200) {
        return {'success': false, 'message': 'HTTP ${res.statusCode}'};
      }
      final decoded = json.decode(res.body);
      final root = (decoded is Map && decoded['result'] != null)
          ? decoded['result']
          : decoded;
      if (root is Map && root['success'] == true) {
        final records = (root['records'] as List? ?? [])
            .map((e) => Justification.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return {'success': true, 'records': records, 'count': root['count']};
      }
      final message = root is Map
          ? (root['message'] ?? root['error'] ?? 'Unexpected response')
          : 'Unexpected response';
      return {'success': false, 'message': message.toString()};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
