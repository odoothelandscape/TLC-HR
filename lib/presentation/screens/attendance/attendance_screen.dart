import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//import 'package:talent_hr/app/baseState.dart';
import 'package:talent_hr/data/api/attendance_api.dart';
import 'package:talent_hr/data/database/dao/attendance_dao.dart';
import 'package:talent_hr/data/database/dao/employee_dao.dart';
import 'package:talent_hr/presentation/screens/dashboard/dashboard_main.dart';
import 'package:talent_hr/utility/style/theme.dart' as style;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/attendance/attendance.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/style/theme.dart';
import '../../../utility/utils/date_util.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/leave_time_picker.dart';
import '../../widgets/no_data.dart';
import '../../widgets/widgets.dart';
import '../base.account/login.dart';
import 'justification_dialog.dart';
import 'justification_list_page.dart';
import 'package:talent_hr/app/locale_controller.dart';

class AttendanceScreen extends StatefulWidget {
  /// 0 = attendance history, 1 = justification requests
  final int initialTab;

  const AttendanceScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  //OdooUser? odooUser;
  Employee? employee;
  var database;
  var employeeDao = EmployeeDao();
  var attendanceDao = AttendanceDao();
  bool noMoreToShow = false;
  String filter = '';
  List<Attendance> attList = [];
  var attendanceApi = AttendanceAPI();
  bool isRead = false;
  var pref;
  late int uid;
  var userLevel;
  var startDate = '';
  var endDate = '';
  var todayDate = '';
  var chosenStartDate = '', chosenEndDate = '';
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  var date;
  bool loading = false;
  late BuildContext _scaffoldCtx;
  double? lat, long;
  FToast? toast;
  var checkInOutTime;
  bool? _isCheckIn = true;
  var lon;
  Attendance? lastAttendance;
  var address;
  var lastAttCheckDate;
  var code;
  late final DateTime init;
  late final DateTime lastDate;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int totalDays = 0;
  bool selectTime = false;
  var password;
  bool createPassword = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  //QRViewController? controller;
  //Barcode? result;

  @override
  void initState() {
    toast = FToast();
    toast!.init(context);
    super.initState();
   
    lastDate = DateTime(3000);
    _loadData();
  }

  int totalDay() => totalDays = endTime.difference(startTime).inDays;

  _loadData() async {
    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(uid);
    todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    //code = 'AX-att-qr';
    //sharePref!.setString('code', code);

    await checkIsCheckIn();

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
    }

    attList = [];

    attList = await attendanceDao.getAttendanceList();

    setState(() {});

    bindData();
  }

  checkIsCheckIn() async {
    lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tempAttendance =
        await attendanceDao.getTodayAttendance(lastAttCheckDate);

    if (tempAttendance == null) {
      pref.setBool('is_check_in', true);
    } else {
      lastAttendance = tempAttendance;
      if (lastAttendance!.check_out_time == '') {
        pref.setBool('is_check_in', false);
      } else {
        pref.setBool('is_check_in', true);
      }
    }

    _isCheckIn = pref.getBool('is_check_in');
  }

  Future bindData() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }
    attList = [];
    await attendanceApi.getAttendanceSetting(employee!.employee_id!);
    await attendanceApi.getAttendanceList(employee!.employee_id!);
    attList = [];
    attList = await attendanceDao.getAttendanceList();

    if (attList.isEmpty) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  Future<void> refreshList() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }
    await bindData();
    EasyLoading.dismiss();
  }

  choiceAction(int result) {
 
    switch (result) {
      case 0: //today
        filter = 'today';
        getAttendanceByFilter(filter, '', '');

        break;
      
      case 4: //this month
        filter = 'custom';

        setState(() {});
        Future.delayed(
          const Duration(seconds: 0),
          () => dateRangeDialog(context),
        );

        break;
    }
  }

/*fetch attendance by filter from server and then local database*/
  getAttendanceByFilter(String filter, String startDate, String endDate) async {
   

    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }

    await attendanceApi.getAttendanceListByFilter(filter, startDate, endDate);
    await bindData2();

    if (!mounted) return;
    if (filter == 'custom') Navigator.pop(context);
  }

  Future bindData2() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }
    attList = [];
    attList = await attendanceDao.getAttendanceList();

    if (attList.isEmpty) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

 

  

  _sendAttendance() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }

    Attendance? att;

    if (_isCheckIn == null || _isCheckIn!) {
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Attendance? attendance;
      attendance =
          await attendanceDao.getTodayAttendanceCheckForCheckIn(todayDate);
      checkInOutTime = DateFormat('H:m a').format(DateTime.now());

      if (attendance != null) {
        EasyLoading.show(status: '................');
        EasyLoading.dismiss();
        toast!.showToast(
          child: Widgets().getWarningToast(context.l10n.alreadyCheckedInToday),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 2),
        );
        return null;
      }
      att = await _insertCheckIn();
    } else {
      att = await _insertCheckout();
    }

    // EasyLoading.show(status: context.l10n.submittingPleaseWait);

    await _syncToServer(att);
    await refreshList();

    EasyLoading.dismiss();

    setState(() {});
  }

  Future<Attendance?> _insertCheckIn() async {
    // Attendance? attendance;
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
   
    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();
    DateTime currentDateTime = DateTime.now();
    String check_in_datetime =
        DateUtil().getSqlDateTime(currentDateTime, 'yyyy-MM-dd HH:mm:ss');

    Attendance att = Attendance(
        0,
        (employee!.employee_name).toString(),
        employee!.employee_id,
        uid,
        todayDate,
        check_in_datetime,
        '',
        checkInOutTime,
        '',
        "0",
        0,
        0,
        0,
        0,
        address,
        address,
        deviceStatus.androidId,
        //androidDeviceInfo.androidId,
        '',
        '',
        'default',
        '',
        '');

   
    return att;
  }

  Future<Attendance?> _insertCheckout() async {
    Attendance? attendance;
    var todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var tempAttendance =
        await attendanceDao.getTodayAttendanceAlreadyCheckIn(todayDate);
    checkInOutTime = DateFormat('H:m a').format(DateTime.now());

    if (tempAttendance != null) {
      attendance = tempAttendance;
      DateTime currentDateTime = DateTime.now();
      String check_out_datetime =
          DateUtil().getSqlDateTime(currentDateTime, 'yyyy-MM-dd HH:mm:ss');

      Attendance att = Attendance(
          attendance!.attendanceId,
          (employee!.employee_name).toString(),
          employee!.employee_id,
          attendance.user_id,
          attendance.date,
          attendance.check_in_datetime,
          check_out_datetime,
          attendance.check_in_time,
          checkInOutTime,
          attendance.working_hr,
          attendance.in_latitude,
          attendance.in_longitude,
          attendance.out_latitude,
          attendance.out_longitude,
          attendance.in_location,
          attendance.out_location,
          attendance.device_id,
          'default',
          attendance.write_date,
          attendance.att_type,
          '',
          '',
          id: attendance.id);
      return att;
    } else {
      return null;
    }
  }

  _syncToServer(Attendance? attendance) async {
   
    if (attendance == null) {
      EasyLoading.dismiss();

      toast!.showToast(
        child: Widgets().getErrorToast(context.l10n.alreadyCheckedInToday),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    var checkInResult;
    EasyLoading.show(status: context.l10n.submittingPleaseWait);

    if (_isCheckIn!) {
      checkInResult = await attendanceApi.createAttendance(attendance, '');
    } else {
      checkInResult = await attendanceApi.checkOutAttendance(attendance, '');
    }



    if (checkInResult['result'] == 'fail') {
      var message;

      if (checkInResult['attendanceMessage'] == '') {
        message = context.l10n.checkInFail;
      } else {
        message = checkInResult['attendanceMessage'];
        if (message == 'Invalid cookie.') {
          EasyLoading.dismiss();
          toast!.showToast(
            child:
                Widgets().getErrorToast(context.l10n.sessionExpired),
            gravity: ToastGravity.BOTTOM,
            toastDuration: const Duration(seconds: 3),
          );
          await pref.setString('jwt_token', "null");
          await Future.delayed(const Duration(seconds: 4));

          if (!mounted) return;
          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return const LoginScreen();
          }), (route) => false);

          return;
        }
      }

      EasyLoading.dismiss();
      toast!.showToast(
        child: Widgets().getErrorToast('$message'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 6),
      );
      return;
    }

    EasyLoading.dismiss();

    if (!mounted) return;
    toast = FToast();
    toast!.init(context); //Custom edit

    var status = checkInResult['attendanceMessage'];

    if (status == 'exist') {
      toast!.showToast(
        child: Widgets()
            .getErrorToast(context.l10n.attendanceDateExists),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    } else if (status == 'in') {
      toast!.showToast(
        child: Widgets().getSuccessToast(context.l10n.checkInSuccessful),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );

      await pref.setBool('is_check_in', false);

      attendance.attendanceId =
          int.parse(checkInResult['attendanceId'].toString());
      await attendanceDao.updateAttendance(attendance);

      var resultId = await attendanceDao.insertSingleAttendance(attendance);

      attendance.id = int.parse(resultId.toString());
      await attendanceDao.updateAttendance(attendance);
      lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var tempAttendance =
          await attendanceDao.getTodayAttendance(lastAttCheckDate);

      lastAttendance = tempAttendance;

      setState(() {});
    } else if (status == 'out') {
   
      toast!.showToast(
        child: Widgets().getSuccessToast(context.l10n.checkOutSuccessful),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );

      await pref.setBool('is_check_in', true);

      attendance.id = attendance.id;
      await attendanceDao.updateAttendance(attendance);

      var tempAttendance =
          await attendanceDao.getTodayAttendance(lastAttCheckDate);

      lastAttendance = tempAttendance;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldCtx = context;
    // SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return const HomeScreen();
        }), (r) {
          return false;
        });

        return false;
      },
      child: DefaultTabController(
        length: 2,
        initialIndex: widget.initialTab,
        child: Scaffold(
          appBar: AppBar(
              leading: InkWell(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return const HomeScreen();
                    }));
                  },
                  child: const Icon(Icons.home)),
              title: Text(
                context.l10n.attendance,
                style: appBarTitleStyle,
              ),
              backgroundColor: style.ColorObj.mainColor,
              actions: [
                Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 10,
                      bottom: 10,
                      right: 10,
                    ),
                    child: Row(
                      children: [
                       InkWell(
                          onTap: () async {
                            EasyLoading.show(
                              status: context.l10n.gettingCurrentLocation,
                            );

                            bool hasGPSPermission = false;

                            if (await Permission.location.isGranted) {
                              hasGPSPermission = true;
                            } else {
                              var status = await Permission.location.request();
                              hasGPSPermission = status.isGranted;
                            }

                            if (!hasGPSPermission) {
                              toast?.showToast(
                                child: Widgets().getWarningToast(
                                  context.l10n.notAllowedLocation,
                                ),
                                gravity: ToastGravity.BOTTOM,
                                toastDuration: const Duration(seconds: 3),
                              );
                            }

                            var location =
                                await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high);

                            EasyLoading.dismiss();

                            toast!.showToast(
                              child: Widgets().getInfoToast(
                                "Lat: ${location.latitude} \nLong: ${location.longitude}",
                              ),
                              gravity: ToastGravity.BOTTOM,
                              toastDuration: const Duration(seconds: 5),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 15.0),
                            child: Icon(
                              Icons.my_location,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: () async {
                              bool checkInternet =
                                  await InternetConnectionChecker()
                                      .hasConnection;
                              if (!mounted) return;
                              if (checkInternet == false) {
                                showDialog(
                                    context: context,
                                    builder: (_) => const CustomEventDialog());
                                return;
                              }
                              setState(() {
                                //attList = [];
                                noMoreToShow = false;
                              });
                              EasyLoading.show(
                                  status: context.l10n.fetchingData);
                              refreshList();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                            )),
                        PopupMenuButton(
                            padding: const EdgeInsets.all(0),
                            child: const Icon(MdiIcons.filterVariantPlus),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  onTap: () {
                                    choiceAction(0);
                                  },
                                  height: 20,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  value: 0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Expanded(
                                            flex: 2,
                                            child: Icon(
                                              MdiIcons.calendarClock,
                                              color: ColorObj.mainColor,
                                            ),
                                          ),
                                          // Expanded(
                                          //     flex: 1, child: Container()),
                                          Expanded(
                                              flex: 4,
                                              child: Text(
                                                context.l10n.today,
                                                textAlign: TextAlign.left,
                                                style: listRow1TextStyle,
                                              )),
                                        ],
                                      ),
                                      const PopupMenuDivider()
                                    ],
                                  ),
                                ),
                               
                              
                               
                                PopupMenuItem(
                                  onTap: () {
                                    choiceAction(4);
                                  },
                                  height: 20,
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  value: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Expanded(
                                            flex: 2,
                                            child: Icon(
                                              MdiIcons.calendarEdit,
                                              color: ColorObj.mainColor,
                                            ),
                                          ),
                                          // Expanded(
                                          //     flex: 1, child: Container()),
                                          Expanded(
                                              flex: 4,
                                              child: Text(context.l10n.custom,
                                                  textAlign: TextAlign.left,
                                                  style: listRow1TextStyle)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ];
                            }),
                      ],
                    )),
              ],
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: context.l10n.history),
                  Tab(text: context.l10n.justifications),
                ],
              )),
          //drawer: drawerWidget(context, employee, odoo, createPassword),
          body: TabBarView(children: [
            _buildHistoryTab(),
            const JustificationListPage(),
          ]),
          bottomNavigationBar: _buildRecordCountBar()),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return attList.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: const Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                             
                              child: Text(
                                context.l10n.date,
                                textAlign: TextAlign.center,
                                style: style.tableHeadingStyle2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: const Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                context.l10n.checkIn,
                                textAlign: TextAlign.center,
                                style: style.tableHeadingStyle2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: const Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                           
                              child: Text(
                                context.l10n.checkOut,
                                textAlign: TextAlign.center,
                                style: style.tableHeadingStyle2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(left: 5, right: 5, top: 5),
                              alignment: Alignment.center,
                              height: 42,
                              //  color: Color(0xff016976),
                              decoration: BoxDecoration(
                                color: const Color(0xff016976),
                                borderRadius: BorderRadius.circular(5),
                              ),
                             
                              child: Text(
                                context.l10n.hours,
                                textAlign: TextAlign.center,
                                style: style.tableHeadingStyle2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                          itemCount: attList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            var dateTime1 = DateFormat('yyyy-MM-dd')
                                .parse(attList[i].date!);

                            final DateFormat format = DateFormat('MMM');

                            var month = format.format(dateTime1);

                            return Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                              ),
                              child: Card(
                                shadowColor: Colors.blue,
                                elevation: 2,
                                color: todayDate == attList[i].date
                                    ? Colors.green
                                    : Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 50,
                                     
                                        child: Text(attList[i].date!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: todayDate ==
                                                        attList[i].date
                                                    ? Colors.white
                                                    : const Color.fromARGB(
                                                        255, 54, 113, 143))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                    
                                        child: Text(attList[i].check_in_time!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                color:
                                                    todayDate == attList[i].date
                                                        ? Colors.white
                                                        : Colors.grey[700])),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                       
                                        child: Text(attList[i].check_out_time!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                color:
                                                    todayDate == attList[i].date
                                                        ? Colors.white
                                                        : Colors.grey[700])),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                       
                                        child: Text(
                                            attList[i].working_hr!.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Regular',
                                                fontSize: 14,
                                                color:
                                                    todayDate == attList[i].date
                                                        ? Colors.white
                                                        : Colors.grey[700])),
                                      ),
                                    ),
                                  ],
                                    ),
                                    if (_hasExtraInfo(attList[i]))
                                      _attendanceExtraRow(attList[i]),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                )
              : noMoreToShow
                  ? noDataWidget(context)
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
  }

  Widget _buildRecordCountBar() {
    return Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.4,
                ),
              ),
            ),
            alignment: Alignment.center,
            height: 25,
            width: double.infinity,
            child: attList.isNotEmpty
                ? Text(
                    '${attList.length} records found',
                    style: normalMediumGreyText,
                  )
                : Text(
                    context.l10n.noRecordsFound,
                    style: normalMediumGreyText,
                  ),
    );
  }

  bool _isMissedCheckout(Attendance att) =>
      att.date != todayDate && (att.check_out_time ?? '').isEmpty;

  bool _hasExtraInfo(Attendance att) =>
      att.check_in_mode == 'outside' ||
      att.check_out_mode == 'outside' ||
      att.is_auto_checkout == 1 ||
      _isMissedCheckout(att);

  Widget _modeChip(String label, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ]),
      );

  /// Per-record source of check-in/out (official vs outside + address),
  /// auto-checkout flag and a justification shortcut.
  Widget _attendanceExtraRow(Attendance att) {
    final bool isToday = todayDate == att.date;
    final Color textColor = isToday ? Colors.white : Colors.grey[700]!;

    String? justifyType;
    if (att.is_auto_checkout == 1) {
      justifyType = 'auto_checkout';
    } else if (_isMissedCheckout(att)) {
      justifyType = 'missed_checkout';
    } else if (att.check_in_mode == 'outside' ||
        att.check_out_mode == 'outside') {
      justifyType = 'outside_location';
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (att.check_in_mode == 'outside')
                _modeChip(context.l10n.inOutside, Icons.location_off, Colors.purple),
              if (att.check_out_mode == 'outside')
                _modeChip(
                    context.l10n.outOutside, Icons.location_off, Colors.deepPurple),
              if (att.is_auto_checkout == 1)
                _modeChip(context.l10n.autoCheckout, Icons.timer_off, Colors.red),
              if (_isMissedCheckout(att))
                _modeChip(
                    context.l10n.missingCheckout, Icons.error_outline, Colors.orange),
              if (justifyType != null)
                SizedBox(
                  height: 26,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8)),
                    onPressed: () {
                      showJustificationDialog(context,
                          type: justifyType!,
                          attendanceId: att.attendanceId,
                          date: att.date);
                    },
                    child:
                        Text(context.l10n.justify, style: TextStyle(fontSize: 12)),
                  ),
                ),
            ],
          ),
          if ((att.check_in_address ?? '').isNotEmpty)
            Text('In: ${att.check_in_address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: textColor)),
          if ((att.check_out_address ?? '').isNotEmpty)
            Text('Out: ${att.check_out_address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: textColor)),
        ],
      ),
    );
  }

/*widget */
  Widget attendanceDataScreen(Attendance attendance) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.date!),
                ),
              ),
            ),
            Container(
              height: 25,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.check_in_time!),
                ),
              ),
            ),
            Container(
              height: 25,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.check_out_time!),
                ),
              ),
            ),
            Container(
              height: 25,
              width: 2,
              color: Colors.grey,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text(attendance.working_hr!.toString()),
                ),
              ),
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1.5,
        )
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;

        chosenStartDate = DateFormat("yyyy-MM-dd").format(selectedStartDate);
      });
    }
    // await bindData();
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEndDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedEndDate) {
      selectedEndDate = picked;

      chosenEndDate = DateFormat("yyyy-MM-dd").format(selectedEndDate);
    }
    setState(() {});

    // await bindData();
  }

  dateRangeDialog(
    BuildContext context,
  ) async {
   
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                //  padding: EdgeInsets.only(left:10,right: 10),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.40,
                child: Column(children: [
                  Container(
                    //   padding: const EdgeInsets.only(left: 30),
                    alignment: Alignment.center,
                    // width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      color: ColorObj.mainColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            context.l10n.chooseDate,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              refreshList();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 40,
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.22,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: TimePickerWidget(
                            //edit border radius in library
                            text: context.l10n.startDate,
                            timePicker: (t) {
                              setState(() {
                                startTime = t;
                                selectTime = true;
                                totalDays = -1;
                              });
                            },
                            init: startTime,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Center(
                            child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: Text(
                            context.l10n.to,
                            style: TextStyle(
                                fontSize: 15,
                                color: ColorObj.textColor,
                                fontWeight: FontWeight.bold),
                          ),
                        )),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        // selectTime
                        //     ?
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: TimePickerWidget(
                            text: context.l10n.endDate,
                            timePicker: (t) {
                              setState(() {
                                endTime = t;
                                totalDays = totalDay();
                                if (totalDays < 0) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ErrorDialog(
                                            title: context.l10n.endDateSelectError,
                                            content: Text(
                                              context.l10n.pleaseSelectCorrectEndDate,
                                              style: TextStyle(
                                                  color: ColorObj.textColor,
                                                  fontSize: 15),
                                            ),
                                            icon: Icons.warning);
                                      });
                                }
                              });
                            },
                            init: endTime,
                            totalDays: totalDays,
                          ),
                        )
                      ],
                    ),
                  ),
                  // const SizedBox(
                  //   height: 40,
                  // ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  SizedBox(
                    //height: MediaQuery.of(context).size.height * 0.05,
                    //padding: const EdgeInsets.only(right: 5),
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: 80,
                            // height: 30,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  refreshList();
                                },
                                child: Text(context.l10n.cancel,
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 16)))),
                        SizedBox(
                            width: 80,
                            // height: 30,
                            child: TextButton(
                                onPressed: () async {
                                 
                                  if (selectTime == false) {
                                    toast!.showToast(
                                      child: Widgets().getWarningToast(
                                          context.l10n.pleaseSelectStartDate),
                                      gravity: ToastGravity.BOTTOM,
                                      toastDuration: const Duration(seconds: 2),
                                    );
                                  }

                                  if (totalDays <= 0) {
                                    toast!.showToast(
                                      child: Widgets().getWarningToast(
                                          context.l10n.pleaseSelectValidDate),
                                      gravity: ToastGravity.BOTTOM,
                                      toastDuration: const Duration(seconds: 2),
                                    );
                                  } else {
                                    getAttendanceByFilter(
                                        filter,
                                        startTime.toString().split(' ')[0],
                                        endTime.toString().split(' ')[0]);
                                  }
                                },
                                child: Text(
                                  context.l10n.confirm,
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ))),
                      ],
                    ),
                  )
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
