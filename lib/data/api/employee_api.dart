import 'package:http/http.dart' as http;
import 'package:talent_hr/app/locale_controller.dart';
import 'package:talent_hr/data/database/dao/employee_dao.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee/employee.dart';

class EmployeeAPI {
  var pref;
  var urlLink;
  var header_cookie;
  var database;
  int? uid;
  int? companyId;
  var employeeDao = EmployeeDao();
  List<Employee> employeeList = [];

  Future<dynamic> getEmployeeList() async {
    pref = await SharedPreferences.getInstance();
    urlLink = await pref.getString('url');
    header_cookie = await pref.getString('header_cookie');
    database = await pref.getString('database');
    uid = await pref.getInt('uid');
    var insertResult;
    var param = {"domain": "[('user_id','=',$uid)]"};
    await employeeDao.deleteEmployeeRecords();

    var url = Uri.parse('$urlLink' 'api/get/employees');
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
          if (payload is Map) {
            insertResult = payload['message'] ??
                payload['error'] ??
                'Unexpected employee response: ${json.encode(payload)}';
          } else {
            final rawBody = res.body.length > 220
                ? '${res.body.substring(0, 220)}...'
                : res.body;
            insertResult = 'Unexpected employee response: $rawBody';
          }
          return;
        }

        if (payload.isEmpty) {
          insertResult =
              'No employee record was found for this user. Please link the user to an employee in Odoo.';
          return;
        }

        List list = payload;
        for (var element in list) {
          Employee employee = Employee(
            int.parse(element['employee_id'].toString()),
            element['employee_name'],
            element['employee_code'],
            '', //element['employee_type']
            element['job_name'],
            element['mobile_phone'],
            element['work_phone'],
            element['parent_id'] != false
                ? int.parse(element['employee_id'].toString())
                : 0,
            element['department_id'], //parent_id
            element['department_name'],
            element['gender'],
            element['birthday'],
            element['email'],
            element['user_id'],
            element['job_grade_name'], //element['reg_number']
            element['image'],
            0, // element['work_schedule_id']
            0,
            0,
            element['approval_level'],
            element['write_date'],
            (element['latitude'] ?? '').toString(),
            (element['longitude'] ?? '').toString(),
            mobile_work_mode: (element['mobile_work_mode'] ?? '').toString(),
          );

          await pref.setString(
              'locations_list', json.encode(element['locations_list'] ?? []));

          employeeList.add(employee);
        }

        insertResult = await employeeDao.insertEmployee(employeeList);
      } else {
        final rawBody = res.body.length > 220
            ? '${res.body.substring(0, 220)}...'
            : res.body;
        insertResult = 'Employee API failed (${res.statusCode}): $rawBody';
      }
    }).catchError((e) {
      insertResult = e.toString();
    });
    return insertResult;
  }
}
