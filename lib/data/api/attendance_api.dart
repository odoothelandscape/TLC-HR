import 'package:http/http.dart' as http;
import 'package:talent_hr/app/locale_controller.dart';
import 'package:talent_hr/data/database/dao/attendance_dao.dart';
import 'package:talent_hr/data/models/attendance/attendance.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Odoo sends `false` for empty char fields — normalize to ''.
String _odooStr(dynamic v) => v is String ? v : '';

class AttendanceAPI {
  var pref;
  var urlLink;
  var header_cookie;
  var database;
  var username;
  int? uid;
  int? companyId;
  var attendanceDao = AttendanceDao();

  Future<dynamic> getAttendanceList(int empId) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    username = await pref.getString('user_name');

    dynamic insertResult = '';
    List<Map<String, dynamic>> listData = [];
    List<Attendance> attendanceList = [];

    var param = {"domain": "[('employee_id','=',$empId)]", "month": DateTime.now().month};
   

    var url = Uri.parse('$urlLink' 'api/get/attendance');
    await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            'Accept-Language': await LocaleController.odooLang(),
            },
            body: json.encode(param))
        .then((res) async {
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);
        final payload = result['result'];
        if (payload is! List) {
          insertResult = payload is Map
              ? (payload['message'] ??
                  payload['error'] ??
                  'Unexpected attendance response')
              : 'Unexpected attendance response';
          return;
        }
        List list = payload;
     

        if (list.isNotEmpty) {
          await attendanceDao.deleteAttendanceRecords();
        }

        for (var element in list) {
          Attendance attendance = Attendance(
              int.parse(element['id'].toString()),
              username,
              0,
              element['user_id'],
              element['date'],
              element['check_in_datetime'],
              element['check_out_datetime'],
              element['check_in_time'],
              element['check_out_time'],
              element['worked_hours'],
              0,
              0,
              0,
              0,
              '',
              '',
              '',
              '',
              element['write_date'],
              '',
              '',
              '',
              check_in_mode: _odooStr(element['check_in_mode']),
              check_out_mode: _odooStr(element['check_out_mode']),
              check_in_address: _odooStr(element['check_in_address']),
              check_out_address: _odooStr(element['check_out_address']),
              is_auto_checkout: element['is_auto_checkout'] == true ? 1 : 0);

          attendanceList.add(attendance);
        }

        insertResult = await attendanceDao.insertAttendance(attendanceList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  Future<dynamic> getAttendanceSetting(int empId) async {
   
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    username = await pref.getString('user_name');
    String insertResult = '';
    List<Map<String, dynamic>> listData = [];
    List<Attendance> attendanceList = [];

  
    var url = Uri.parse('$urlLink' 'api/get/attendance_setting');
    await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            'Accept-Language': await LocaleController.odooLang(),
            },
            body: json.encode({}))
        .then((res) async {
   
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);

        final records = result['result']["records"];

        // Backward-compatible single value (employee override > company).
        await pref.setString(
            'attendanceDistance', records['map_distance'].toString());

        // New contract: backend sends per-location effective_distance
        // (already resolved: employee override > allowed_area > global).
        final locations = records['locations'];
        if (locations is List) {
          await pref.setString('attendance_locations', json.encode(locations));
        } else {
          await pref.remove('attendance_locations');
        }

        // Freshest allowed work mode — backend v19.0.3.4 returns it here too;
        // used to gate the Remote/Field/Outside buttons before check-in.
        final settingMode = records['mobile_work_mode'];
        if (settingMode is String && settingMode.isNotEmpty) {
          await pref.setString('mobile_work_mode_setting', settingMode);
        }
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  Future<dynamic> getAttendanceListByFilter(
      String filterType, String startDate, String endDate) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    username = await pref.getString('user_name');
    var insertResult;
    List<Map<String, dynamic>> listData = [];
    List<Attendance> attendanceList = [];

    var param = {
      "user_id": uid,
      "filter_type": filterType,
      'start_date': startDate,
      'end_date': endDate
    };
   
   

    var url = Uri.parse('$urlLink' 'api/get/attendance_filter');
    await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            'Accept-Language': await LocaleController.odooLang(),
            },
            body: json.encode(param))
        .then((res) async {
      if (res.statusCode == 200) {
        Map<String, dynamic> result = json.decode(res.body);
        final payload = result['result'];
        if (payload is! List) {
          insertResult = payload is Map
              ? (payload['message'] ??
                  payload['error'] ??
                  'Unexpected attendance response')
              : 'Unexpected attendance response';
          return;
        }
        List list = payload;
        if (list.isNotEmpty) {
          await attendanceDao.deleteAttendanceRecords();
        }
        int i = 1;

        for (var element in list) {
          Attendance attendance = Attendance(
              int.parse(element['id'].toString()),
              username,
              0,
              element['user_id'],
              element['date'],
              element['check_in_datetime'],
              element['check_out_datetime'],
              element['check_in_time'],
              element['check_out_time'],
              element['worked_hours'],
              0,
              0,
              0,
              0,
              '',
              '',
              '',
              '',
              element['write_date'],
              '',
              '',
              '',
              check_in_mode: _odooStr(element['check_in_mode']),
              check_out_mode: _odooStr(element['check_out_mode']),
              check_in_address: _odooStr(element['check_in_address']),
              check_out_address: _odooStr(element['check_out_address']),
              is_auto_checkout: element['is_auto_checkout'] == true ? 1 : 0);

          attendanceList.add(attendance);
          i++;
        }

        insertResult = await attendanceDao.insertAttendance(attendanceList);
      } else {
        insertResult = 'Something Wrong';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }

  var createResult;
  Future<dynamic> createAttendance(Attendance attendance, var qrCode) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var url = Uri.parse('$urlLink' 'api/create/attendance');
    var param = {
      "employee_id": attendance.employee_id,
      "check_in": attendance.check_in_datetime.toString(),
      "remarks": attendance.reason,
      "device_id": attendance.device_id,
      "in_latitude": attendance.in_latitude,
      "in_longitude": attendance.in_longitude,
      "work_mode": attendance.work_mode ?? 'office',
      "accuracy": attendance.accuracy,
      // 'outside' skips the backend geofence but still stores coordinates
      "mode": attendance.check_in_mode ?? 'office',
      "in_address": attendance.check_in_address ?? '',
    };
    var response = await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            'Accept-Language': await LocaleController.odooLang(),
          
            },
            body: json.encode(param))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['result']['success'] == true) {
          var attendanceId = result['result']['attendance_id'];
          var message = result['result']['attendance_message'];
          createResult = {
            'result': 'success',
            'attendanceId': int.parse(attendanceId.toString()),
            'attendanceMessage': message,
          };
        } else {
          // Backend rejections (geofence / work-mode restriction) come as
          // {success: false, message: "..."} — show the server text verbatim.
          var message =
              result['result']['message'] ?? result['result']['error'] ?? '';

          createResult = {
            'result': 'fail',
            'attendanceId': null,
            'attendanceMessage': message,
          };
        }
      } else {
        createResult = {
          'result': 'fail',
          'attendanceId': null,
          'attendanceMessage': response.statusCode.toString(),
        };
      }
    }).catchError((e) {
      createResult = {
        'result': 'fail',
        'attendanceId': null,
        'attendanceMessage': '$e \n \n Please check whether did you check out last day.',
      };
    });

    return createResult;
  }

  var updateResult;
  Future<dynamic> checkOutAttendance(Attendance attendance, var qrCode) async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var url = Uri.parse('$urlLink' 'api/update/attendance');
   

    var param = {
      "check_out": attendance.check_out_datetime.toString(),
      "attendance_id": attendance.attendanceId,
      'remarks': attendance.reason,
      "out_latitude": attendance.out_latitude,
      "out_longitude": attendance.out_longitude,
      "work_mode": attendance.work_mode ?? 'office',
      "mode": attendance.check_out_mode ?? 'office',
      "out_address": attendance.check_out_address ?? '',
    };
 

    var response = await http
        .post(url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'cookie': header_cookie,
              'db_name': database,
            'Accept-Language': await LocaleController.odooLang(),
           
            },
            body: json.encode(param))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        if (result['result']['success'] == true) {
          var attendanceId = result['result']['attendance_id'];
          var message = result['result']['attendance_message'];
          updateResult = {
            'result': 'success',
            'attendanceId': int.parse(attendanceId.toString()),
            'attendanceMessage': message,
          };

        
        } else {
          // Backend rejections come as {success: false, message: "..."} —
          // older payloads used 'error'; coalesce so the real reason shows.
          var message =
              result['result']['message'] ?? result['result']['error'] ?? '';
          updateResult = {
            'result': 'fail',
            'attendanceId': null,
            'attendanceMessage': message,
          };
        }
      } else {
        updateResult = {
          'result': 'fail',
          'attendanceId': null,
          'attendanceMessage': response.statusCode.toString(),
        };
      }
    }).catchError((e) {
      updateResult = {
        'result': 'fail',
        'attendanceId': null,
        'attendanceMessage': e.toString(),
      };
    });

    return updateResult;
  }
}
