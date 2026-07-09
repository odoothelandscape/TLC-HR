import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/locale_controller.dart';
import '../models/request/employee_request_models.dart';

/// REST client for the HST Employee Requests API.
/// Reuses the sc_hr_mobile_connector session cookie stored at login.
class RequestsAPI {
  Future<Map<String, String>> _headers() async {
    final pref = await SharedPreferences.getInstance();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'cookie': pref.getString('header_cookie') ?? '',
      'db_name': pref.getString('database') ?? '',
      'Accept-Language': await LocaleController.odooLang(),
    };
  }

  Future<String> _baseUrl() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('url') ?? '';
  }

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, String>? query]) async {
    final base = await _baseUrl();
    final lang = await LocaleController.odooLang();
    var uri = Uri.parse('$base$path');
    uri = uri.replace(
        queryParameters: {...uri.queryParameters, 'lang': lang, ...?query});
    final res = await http.get(uri, headers: await _headers());
    return _decode(res);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final base = await _baseUrl();
    final res = await http.post(Uri.parse('$base$path'),
        headers: await _headers(), body: json.encode(body));
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode == 401) {
      return {'success': false, 'error': 'session_expired'};
    }
    try {
      final data = json.decode(res.body);
      if (data is Map<String, dynamic>) return data;
      return {'success': false, 'error': 'Unexpected response'};
    } catch (_) {
      return {
        'success': false,
        'error': 'Server error (${res.statusCode})',
      };
    }
  }

  /// GET /api/requests/sections
  Future<List<RequestSection>> getSections() async {
    final data = await _get('api/requests/sections');
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to load sections');
    }
    return ((data['sections'] ?? []) as List)
        .map((e) => RequestSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// GET /api/requests/form?category_id=
  Future<RequestFormSchema> getForm(int categoryId) async {
    final data =
        await _get('api/requests/form', {'category_id': '$categoryId'});
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to load form');
    }
    return RequestFormSchema.fromJson(data);
  }

  /// POST /api/requests/create
  Future<RequestDetail> createRequest({
    required int categoryId,
    required Map<String, dynamic> values,
    String? reason,
    Map<String, int>? roleChoices,
    int? relatedLoanId,
    List<Map<String, String>>? attachments,
    bool confirm = true,
  }) async {
    final body = <String, dynamic>{
      'category_id': categoryId,
      'values': values,
      'confirm': confirm,
    };
    if (reason != null && reason.isNotEmpty) body['reason'] = reason;
    if (roleChoices != null && roleChoices.isNotEmpty) {
      body['role_choices'] = roleChoices;
    }
    if (relatedLoanId != null) body['related_loan_id'] = relatedLoanId;
    if (attachments != null && attachments.isNotEmpty) {
      body['attachments'] = attachments;
    }
    final data = await _post('api/requests/create', body);
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to submit request');
    }
    return RequestDetail.fromJson(data);
  }

  /// GET /api/requests/my
  Future<MyRequestsPage> getMyRequests({
    String? status,
    String? sectionCode,
    int offset = 0,
    int limit = 40,
  }) async {
    final query = <String, String>{'offset': '$offset', 'limit': '$limit'};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (sectionCode != null && sectionCode.isNotEmpty) {
      query['section_code'] = sectionCode;
    }
    final data = await _get('api/requests/my', query);
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to load requests');
    }
    final list = (data['requests'] ?? data['data'] ?? []) as List;
    return MyRequestsPage(
      requests: list
          .map((e) => MyRequestItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: data['total'] is int
          ? data['total']
          : int.tryParse('${data['total']}') ?? list.length,
    );
  }

  /// GET /api/requests/detail?request_id=
  Future<RequestDetail> getDetail(int requestId) async {
    final data =
        await _get('api/requests/detail', {'request_id': '$requestId'});
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to load detail');
    }
    return RequestDetail.fromJson(data);
  }

  /// GET /api/requests/pending — approval inbox for the logged-in user.
  Future<List<MyRequestItem>> getPendingApprovals() async {
    final data = await _get('api/requests/pending');
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to load inbox');
    }
    final list = (data['requests'] ?? data['data'] ?? []) as List;
    return list
        .map((e) => MyRequestItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// POST /api/requests/approve
  Future<void> approve(int requestId,
      {bool override = false, String? comment}) async {
    final data = await _post('api/requests/approve', {
      'request_id': requestId,
      'override': override,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Approve failed');
    }
  }

  /// POST /api/requests/refuse
  Future<void> refuse(int requestId, {String? reason}) async {
    final data = await _post('api/requests/refuse', {
      'request_id': requestId,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Refuse failed');
    }
  }

  /// POST /api/requests/cancel
  Future<void> cancel(int requestId) async {
    final data = await _post('api/requests/cancel', {'request_id': requestId});
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Cancel failed');
    }
  }

  /// GET /api/loans/my
  Future<List<MyLoan>> getMyLoans({String? state}) async {
    final data = await _get(
        'api/loans/my', state == null ? null : {'state': state});
    if (data['success'] != true) {
      throw ApiException(data['error']?.toString() ?? 'Failed to load loans');
    }
    final list = (data['loans'] ?? data['data'] ?? []) as List;
    return list
        .map((e) => MyLoan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class MyRequestsPage {
  final List<MyRequestItem> requests;
  final int total;
  MyRequestsPage({required this.requests, required this.total});
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  bool get isSessionExpired => message == 'session_expired';

  @override
  String toString() =>
      isSessionExpired ? 'Session expired, please login again' : message;
}
