import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:talent_hr/presentation/screens/payslip/pay_slip.dart';
import 'package:talent_hr/presentation/widgets/no_data.dart';
import 'package:talent_hr/utility/style/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/api/pay_slip_api.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/pay_slip/pay_slip.dart';
import '../../widgets/custom_event_dialog.dart';
import '../dashboard/dashboard_main.dart';

class PaySlipListScreen extends StatefulWidget {
  const PaySlipListScreen({Key? key}) : super(key: key);

  @override
  State<PaySlipListScreen> createState() => _PaySlipListScreenState();
}

class _PaySlipListScreenState extends State<PaySlipListScreen> {
  int p = 0;
  var paySlipApi = PaySlipAPI();
  NumberFormat numberFormat = NumberFormat("#,###.00", "en_US");
  var pref;
  int? userId;
  Employee? employee;
  var employeeDao = EmployeeDao();
  var password;
  bool createPassword = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   
    loadData();
  }

  void dispose() {
    super.dispose();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();
    userId = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(userId!);
    pref.setInt('paySlipNotiCount', 0);
    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomeScreen();
        }), (r) {
          return false;
        });
 

        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: InkWell(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return HomeScreen();
                    }));
                  },
                  child: Icon(Icons.home)),
            elevation: 0,
            backgroundColor: ColorObj.mainColor,
            title: Text(
              "Pay Slip",
              style: TextStyle(fontSize: 16),
            ),
          ),

          body: FutureBuilder<List<PaySlipModel>>(
              future: PaySlipAPI.paySlip(context),
              builder: (context, snapshot) {
              
                if (snapshot.hasError) {
                
                  return noDataWidget();
                } else if (snapshot.hasData) {
              

                  return snapshot.data!.length == 0
                      ? noDataWidget()
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                          

                            var dmyString = snapshot.data![index].dateTo;
                            var dateTime1 =
                                DateFormat('yyyy-MM-dd').parse(dmyString);

                            final DateFormat format = DateFormat('MMM');

                            var month = format.format(dateTime1);

                            return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PaySlipScreen(
                                            snapshot.data![index].dateFrom,
                                            snapshot.data![index].dateTo,
                                            snapshot.data![index]))),
                                child: Card(
                                    child: Container(
                                  color: Color(0xff2d70be), //0xff007fc0
                                  child: Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              child: Text(
                                                month,
                                                style: normalLargeWhiteText,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                
                                                  Row(
                                                    children: [
                                                      Text(
                                                        snapshot.data![index]
                                                            .refrence,
                                                        style:
                                                            listRow1TextStyle,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // snapshot.data![index]. == 'NET'  ?
                                                      Text(
                                                        numberFormat.format(
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .net) +
                                                            '',
                                                        style:
                                                            listRow2TextStyle,
                                                      ),
                                                      Text(
                                                        snapshot.data![index]
                                                                .dateTo
                                                                .substring(
                                                                    8, 10) +
                                                            '-' +
                                                            snapshot
                                                                .data![index]
                                                                .dateTo
                                                                .substring(
                                                                    5, 7) +
                                                            '-' +
                                                            snapshot
                                                                .data![index]
                                                                .dateTo
                                                                .substring(
                                                                    0, 4),
                                                        style:
                                                            normalMediumBalckText,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ]),
                                  ),
                                )));
                         
                          });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })),
    );
  }
}
