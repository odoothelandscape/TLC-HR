import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:talent_hr/data/database/dao/employee_dao.dart';
import 'package:talent_hr/data/models/employee/employee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/screens/base.account/login.dart';
import '../../presentation/widgets/widgets.dart';
import '../models/pay_slip/pay_slip.dart';

class PaySlipAPI {
  static String? urlLink;
  static String? header_cookie;
  static String? database;
  static var uid;

  static Future<List<PaySlipModel>> paySlip(context) async {
    var pref = await SharedPreferences.getInstance();
    urlLink = pref.getString('url');
    header_cookie = pref.getString('header_cookie');
    database = pref.getString('database');
    uid = pref.getInt('uid');
    var employeeDao = EmployeeDao();
    Employee employee = await employeeDao.getSingleEmployeeById(uid);
    var param = {
 
     'state':'paid',
      "month": 20
    };
    var url = Uri.parse('$urlLink' 'api/get/payslip');
    Response response = await post(url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'db_name': database!,
          'cookie': header_cookie!
      
        },
        body: jsonEncode(param));
    log("code : ${response.statusCode}");
    List<PaySlipModel> modelList = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      if (result['result']['success'] == true) {
        List list = result['result']['records'];

        if (list.isNotEmpty) {
          for (int i = 0; i < list.length; i++) {
            PaySlipModel paySlipModel = PaySlipModel(
                employeeName: list[i]['employee_name'],
                address: list[i]['email'],
                refrence: '',
                department: list[i]['department_name'],
                position: list[i]['position'],
                // job_grade: employee.job_grade!,
                job_grade: '',
                idNumber: list[i]['id'],
                dateFrom: list[i]['date_from'],
                dateTo: list[i]['date_to'],
                // registerNum: list[i]['employee_code'],
                registerNum: '',
                gross: 0,
                net: double.parse(list[i]['net_wage'].toString()),
                payLineList: list[i]['pay_line_ids']);
            modelList.add(paySlipModel);
          }

         

          if (modelList.isNotEmpty) {
            await pref.setInt('payslipCount', modelList.length);
          } else {
            await pref.setInt('payslipCount', 0);
          }
        }
      } else {
        var message = result['result']['error'];
        if (message == 'Invalid cookie.') {
          FToast toast = FToast();
          toast.init(context);
          toast.showToast(
            child:
                Widgets().getErrorToast('Session Expired.Please login again.'),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
          await pref.setString('jwt_token', "null");
          await Future.delayed(const Duration(seconds: 2));

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return  LoginScreen();
          }), (route) => false);
        }
      }
    } else {
      await pref.setInt('payslipCount', 0);
      throw ("Can't fatch the API");
    }
    return modelList;
  }

  Future<dynamic> paySlipList() async {
    var pref = await SharedPreferences.getInstance();
    urlLink = pref.getString('url');
    header_cookie = pref.getString('header_cookie');
    database = pref.getString('database');
    uid = pref.getInt('uid');
    var employeeDao = EmployeeDao();
    Employee employee = await employeeDao.getSingleEmployeeById(uid);
    var param = {
   
      'state':'paid',
      "month": 20
    };
    var resultData = 'fail';
    var url = Uri.parse('$urlLink' 'api/get/payslip');
    Response response = await post(url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'db_name': database!,
          'cookie': header_cookie!
         
        },
        body: jsonEncode(param));
    log("code : ${response.statusCode}");
    List<PaySlipModel> modelList = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      if (result['result']['success'] == true) {
        List list = result['result']['records'];

        if (list.isNotEmpty) {
          for (int i = 0; i < list.length; i++) {
            PaySlipModel paySlipModel = PaySlipModel(
                employeeName: list[i]['employee_name'],
                address: list[i]['email'],
                refrence: '',
                department: list[i]['department_name'],
                position: list[i]['position'],
                // job_grade: employee.job_grade!,
                job_grade: '',
                idNumber: list[i]['id'],
                dateFrom: list[i]['date_from'],
                dateTo: list[i]['date_to'],
                registerNum: '',
                gross: 0,
                net: double.parse(list[i]['net_wage'].toString()),
                payLineList: list[i]['pay_line_ids']);

            modelList.add(paySlipModel);
          }

          if (modelList.isNotEmpty) {
            await pref.setInt('payslipCount', modelList.length);
          } else {
            await pref.setInt('payslipCount', 0);
          }
          resultData = 'success';
        }
      } else {
        await pref.setInt('payslipCount', 0);
        var message = result['result']['error'];
        resultData = 'fail';
      }
    } else {
      await pref.setInt('payslipCount', 0);
      throw ("Can't fatch the API");
    }
    return resultData;
  }

  static Future<List<PaySlipModel>> getPaySlip() async {
    var pref = await SharedPreferences.getInstance();
    urlLink = pref.getString('url');
    header_cookie = pref.getString('header_cookie');
    database = pref.getString('database');
    uid = pref.getInt('uid');
    var employeeDao = EmployeeDao();
 
    Employee employee = await employeeDao.getSingleEmployeeById(uid);
    var param = {
     
      'state':'paid',
      "month": 20
    };
    var url = Uri.parse('$urlLink' 'api/get/payslip');
    Response response = await post(url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'db_name': database!,
          'cookie': header_cookie!
        
        },
        body: jsonEncode(param));
    log("code : ${response.statusCode}");
    List<PaySlipModel> modelList = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      if (result['result']['success'] == true) {
        List list = result['result']['records'];

        var thisMonth = DateFormat('MM').format(DateTime.now());

        var monthName = DateFormat.MMMM().format(DateTime.now());
        var thisYear = DateFormat('yyyy').format(DateTime.now());

        if (list.isNotEmpty) {
          for (int i = 0; i < list.length; i++) {
            if (list[i]['date_to'].toString().substring(5, 7) == thisMonth &&
                list[i]['date_to'].toString().substring(0, 4) == thisYear) {
              await pref.setBool('runPaySlipForThisMonth', true);
              PaySlipModel paySlipModel = PaySlipModel(
                  employeeName: list[i]['employee_name'],
                  address: list[i]['email'],
                  refrence: '',
                  department: list[i]['department_name'],
                  position: list[i]['position'],
                  job_grade: employee.job_grade!,
                  idNumber: list[i]['id'],
                  dateFrom: list[i]['date_from'],
                  dateTo: list[i]['date_to'],
                  registerNum: list[i]['employee_code'],
                  gross: 0,
                  net: double.parse(list[i]['net_wage'].toString()),
                  payLineList: list[i]['pay_line_ids']);

              modelList.add(paySlipModel);
              await pref.setInt('paySlipNotiCount', 1);
              await pref.setBool('runPaySlipForThisMonth', true);

             

              
            }
          }
        }
      
      } else {
        var message = result['result']['error'];
      }
    } else {
     
      throw ("Can't fatch the API");
    }
    return modelList;
  }

 
}
