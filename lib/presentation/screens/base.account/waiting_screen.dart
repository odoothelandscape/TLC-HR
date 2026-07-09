import 'dart:async';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talent_hr/data/api/attendance_api.dart';
import 'package:talent_hr/data/api/employee_api.dart';
import 'package:talent_hr/data/api/expense_api.dart';
import 'package:talent_hr/data/api/pay_slip_api.dart';
import 'package:talent_hr/data/database/dao/attachment_dao.dart';
import 'package:talent_hr/data/database/dao/attendance_dao.dart';
import 'package:talent_hr/data/database/dao/employee_dao.dart';
import 'package:talent_hr/data/database/dao/holiday_dao.dart';
import 'package:talent_hr/data/database/dao/leave_dao.dart';
import 'package:talent_hr/data/database/dao/leave_reason_dao.dart';
import 'package:talent_hr/data/database/dao/leave_remain.dart';
import 'package:talent_hr/data/database/dao/leave_type_dao.dart';
// Removed as the file does not exist
import 'package:talent_hr/data/database/dao/payslip_dao.dart';
import 'package:talent_hr/data/database/dao/payslip_line_dao.dart';
import 'package:talent_hr/presentation/screens/dashboard/dashboard_main.dart';
//import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/expense_product_api.dart';
import '../../../data/api/expense_tax_api.dart';
import '../../../data/api/leave_api.dart';
import '../../../data/api/login_api.dart';
import '../../../data/helper/constant.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/share/share_component.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import 'login.dart';
import 'reject_screen.dart';
import 'package:talent_hr/app/locale_controller.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  var employeeDao = EmployeeDao();
  var holidayDao = HolidayDao();
  var leaveTypeDao = LeaveTypeDao();
  var leaveRemainDao = LeaveRemainDao();
  var attendanceDao = AttendanceDao();
  var leaveDao = LeaveDao();
  var payslipDao = PayslipDao();
  var payslipLineDao = PayslipLineDao();
  var leaveReasonDao = LeaveReasonDao();
  var attachmentDao = AttachmentDao();
  FToast? toast;
  Timer? timer;
  Employee? employee;
  var deviceState = '';
  var loginApi = loginAPI();
  late DeviceInfoPlugin deviceInfoPlugin;
  late AndroidDeviceInfo androidDeviceInfo;

  var employeeApi = EmployeeAPI();
  var attendanceApi = AttendanceAPI();
  var leaveApi = LeaveAPI();
  var expenseApi = ExpenseAPI();
  var expProductApi = ExpenseProductAPI();
  var expenseTaxApi = ExpenseTaxAPI();
  late BuildContext _scaffoldCtx;

  @override
  void initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      //..loadingStyle = EasyLoadingStyle.light
      ..lineWidth = 0.5
      ..indicatorSize = 45.0
      ..radius = 5.0
      ..maskColor = Colors.grey.withOpacity(0.5)
      ..userInteractions = false
      ..backgroundColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light
      ..textColor = Colors.black
      ..indicatorColor = Colors.black
      ..dismissOnTap = false;
    downloadData();
  }

  downloadData() async {
    var pref = await SharedPreferences.getInstance();
    var userId = pref.getInt('uid');

    await checkDeviceActivation();
    if (!mounted) return;
    final waitingStage = pref.getString('waitingStage');
    if (waitingStage == 'false') {
      return;
    }

    var employeeSyncResult = await employeeApi.getEmployeeList();
    if (employeeSyncResult != 'success') {
      toast!.showToast(
        child: Widgets().getErrorToast(employeeSyncResult.toString()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      return;
    }

    checkDeviceActivation();
    setState(() {});

    Employee? employee = await employeeDao.getSingleEmployeeById(userId!);
    if (employee == null) {
      toast!.showToast(
        child: Widgets().getErrorToast(
            'Employee data was not found after sync. Please check the Odoo employee-user link.'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      return;
    }
    toast!.showToast(
      child: Widgets().getDownloadToast(context.l10n.employeeDataDownloaded),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

    var attendanceSyncResult =
        await attendanceApi.getAttendanceList(employee.employee_id!);
    if (attendanceSyncResult != 'success') {
      toast!.showToast(
        child: Widgets().getErrorToast(attendanceSyncResult.toString()),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      return;
    }
    toast!.showToast(
      child: Widgets().getDownloadToast(context.l10n.attendanceDataDownloaded),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

  

    await expenseApi.getExpenseListOnline();
    await expProductApi.getExpenseProductListOnline();

    await expenseTaxApi.getExpenseTaxListOnline();
    toast!.showToast(
      child: Widgets().getDownloadToast(context.l10n.paymentDataDownloaded),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

    await leaveApi.getLeaveRemainingList();
    await leaveApi.getLeaveList();
    await leaveApi.getLeaveTypeList();
    // await leaveApi.getUpcomingHolidayList();
    toast!.showToast(
      child: Widgets().getDownloadToast(context.l10n.leaveDataDownloaded),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

   
  
    var paySlipApi = PaySlipAPI();
    await paySlipApi.paySlipList();
    toast!.showToast(
      child: Widgets().getDownloadToast(context.l10n.payslipDataDownloaded),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );

    timer = Timer.periodic(
        const Duration(seconds: 5), (timer) => checkDeviceActivation());
    // });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkDeviceActivation() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (checkInternet == false) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }
    var pref = await SharedPreferences.getInstance();
    var deviceState = '';
    var loginApi = loginAPI();
    // DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    // AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();

    deviceState = await loginApi.checkDevice(deviceStatus.androidId);


    if (deviceState == 'waiting') {
      await pref.setString('waitingStage', 'true');
    } else if (deviceState == 'approve') {
      await pref.setString('waitingStage', 'false');
      await pref.setBool(Constant.IS_APPROVED, true);
      dispose();
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return const HomeScreen();
      }));
    } else if (deviceState == 'reject') {
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return const RejectScreen();
      }));
    } else if (deviceState == 'Invalid cookie.') {
      toast!.showToast(
        child: Widgets().getErrorToast(context.l10n.sessionExpired),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      await pref.setString('jwt_token', "null");
      await Future.delayed(const Duration(seconds: 4));
      // timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted) return;
      Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) {
        return const LoginScreen();
      }), (route) => false);
    } else {
      toast!.showToast(
        child: Widgets().getErrorToast(deviceState),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldCtx = context;
    //SizeConfig().init(context);
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.waiting,
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            context.l10n.approvalOrDownload,
            style: TextStyle(
                color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
          ),
      
        ],
      ),
    ));
  }
}
