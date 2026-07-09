import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:talent_hr/data/api/attendance_api.dart';
import 'package:talent_hr/data/database/dao/attendance_dao.dart';
import 'package:talent_hr/data/database/dao/employee_dao.dart';
import 'package:talent_hr/data/database/dao/hours_dao.dart';
import 'package:talent_hr/data/database/dao/leave_dao.dart';
import 'package:talent_hr/data/database/dao/payslip_dao.dart';
import 'package:talent_hr/presentation/screens/expense/expense_request_history_list_page.dart';
import 'package:talent_hr/presentation/screens/payslip/pay_slip_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/biometric_service.dart';
import '../../../data/api/employee_api.dart';
import '../../../data/database/dao/expense/expense_dao.dart';
import '../../../data/database/dao/leave_remain.dart';
import '../../../data/models/attendance/attendance.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/expense/expense/expense.dart';
import '../../../data/models/leave/leave.dart';
import '../../../data/models/leave_remain/leave_remain.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/style/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../data/api/attendance_justification_api.dart';
import '../../../utility/utils/attendance_permission_checker.dart';
import '../../../utility/utils/reverse_geocode.dart';
import '../attendance/justification_dialog.dart';
import '../../../utility/utils/date_util.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import '../attendance/attendance_screen.dart';
import '../employee/employee_detail.dart';
import '../discuss/discuss_screen.dart';
import '../requests/hr_admin_screen.dart';
import '../requests/approvals_inbox_screen.dart';
import '../requests/my_loans_screen.dart';
import 'package:talent_hr/app/locale_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isvisible = false;
  bool isVisiable1 = false;
  bool isVisiable2 = false;
  var employeeDao = EmployeeDao();
  var leaveDao = LeaveDao();
  Employee? employee;
  var hoursDao = HoursDao();
  var payslipDao = PayslipDao();
  var attendanceDao = AttendanceDao();
  var expenseDao = ExpenseDao();
  int payslipCount = 0;
  int leaveCount = 0;
  int expenseCount = 0;
  int attendanceCount = 0;
  bool? _isCheckIn = true;
  Attendance? lastAttendance;
  SharedPreferences? _sharedPreferences;
  late Timer timer;
  var timeForNow = '';
  bool? clickedCheckIn;
  bool? clickedCheckOut;
  bool showGreetingContainer = false;
  FToast? toast;
  Position? currentLocation;
  double? lat, lon = 0;
  String address = "";
  var lastAttCheckDate = '';
  var checkInOutTime;
  var employeeApi = EmployeeAPI();
  var attendanceApi = AttendanceAPI();
  var pref;
  var uid;
  bool noMoreToShow = false;
  final _timeNotifier = ValueNotifier<String>('');
  final _notiCountNotifier = ValueNotifier<String>('');
  final _paySlipCountNotifier = ValueNotifier<String>('');
  var passwordController = TextEditingController();
  var confirmPwController = TextEditingController();
  bool confirmPassword = false;
  final String _debugLabelString = "";
  String? fcm_token = '';
  var password;
  bool createPassword = false;
  var leaveRemainDao = LeaveRemainDao();
  var leaveRemainCount = 0.0;
  var currentPwController = TextEditingController();
  int notificationCount = 0;
  int instructionCount = 0;
  int? travelAllowanceCount = 0;
  Uint8List? bytes;
  late Position userPosition;
  String dayName = '';
  final bool _isOfficeSelected = true;
  String _pendingWorkMode = 'office'; // set by work-mode dialog before check-in
  bool _pendingOutsideMode = false; // context.l10n.workFromOutside toggle state

  @override
  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);

    // Justification decisions (approve/reject/escalate) arrive as FCM data
    // messages: {"type": "attendance_justification", "justification_id",
    // "state"} — refresh the requests list and notify the employee.
    FirebaseMessaging.onMessage.listen(_onJustificationPush);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == 'attendance_justification') {
        justificationRefreshTick.value++;
        if (!mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AttendanceScreen(initialTab: 1)));
      }
    });
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
    bool isOfficeSelected = true;

    // scheduleAlarm('');
    loadData();
  }

  loadData() {
    _loadData();
    getCurrentTime();
  }

  String getTodayFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE MMMM d - yyyy').format(now);
  }

  _loadData() async {
    pref = await SharedPreferences.getInstance();

    dayName = DateFormat('EEEE').format(DateTime.now());

    _paySlipCountNotifier.value = payslipCount.toString();

    List<Leave> leaveList = await leaveDao.getLeaveList();
    leaveCount = leaveList.length;

    List<LeaveRemain> leaveRemainList = [];
    leaveRemainList = await leaveRemainDao.getLeaveRemainList();
    List<Expense> expenseList = [];
    expenseList = await expenseDao.getExpenseList();
    expenseCount = expenseList.length;
    List<Attendance> attendanceList = [];
    attendanceList = await attendanceDao.getAttendanceList();
    attendanceCount = attendanceList.length;

    if (leaveRemainList.isNotEmpty) {
      for (var element in leaveRemainList) {
        leaveRemainCount = leaveRemainCount + element.remaining_days!;
      }
    }
    var payslipCountTemp = await pref.getInt('payslipCount');
    if (payslipCountTemp != null && payslipCountTemp > 0) {
      payslipCount = payslipCountTemp;
      _paySlipCountNotifier.value = payslipCount.toString();
    }
    if (payslipCountTemp == 0) {
      setState(() {});
    }

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
      confirmPassword = true;
    }

    pref.setBool('loginned', true); //login success and reach home
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

    uid = await pref.getInt('uid');

    dynamic employeeSyncResult;
    employee = await employeeDao.getSingleEmployeeById(uid!);
    if (employee == null) {
      employeeSyncResult = await employeeApi.getEmployeeList();
      if (employeeSyncResult == 'success') {
        employee = await employeeDao.getSingleEmployeeById(uid!);
      }
    }
    if (employee == null) {
      if (!mounted) return;
      toast!.showToast(
        child: Widgets().getErrorToast(
            employeeSyncResult == null
                ? context.l10n.employeeDataMissing
                : 'Employee data is missing on this device. Sync result: $employeeSyncResult'),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
      return;
    }
    // await instructionApi.getInstructionList(employee!.employee_id!);
    // instructionCount = await pref.getInt('instructionCount');

    // travelAllowanceList = await travelAllowanceDao.getTravelAllowanceList();
    // travelAllowanceCount = travelAllowanceList.length;
    await attendanceApi.getAttendanceSetting(employee!.employee_id!);
    if (employee!.avatar != '') {
      bytes = base64.decode("${employee!.avatar}");
    } else {
      bytes = null;
    }

    setState(() {});
  }

  getCurrentTime() async {
    pref = await SharedPreferences.getInstance();
    var now1 = DateTime.now();
    var thisDay1 = '';
    thisDay1 = now1.day.toString();
    var thisMonth = DateFormat('MM').format(DateTime.now());

    var count = pref.getInt('paySlipNotiCount');
    _notiCountNotifier.value = count.toString();

    if (thisMonth == "04" ||
        thisMonth == "06" ||
        thisMonth == "09" ||
        thisMonth == "11") {
      if (thisDay1 != '30') {
        pref.setBool('runPaySlipForThisMonth', false);
      }
    } else if (thisMonth == "02") {
      if (thisDay1 != '28' && thisDay1 != '29') {
        pref.setBool('runPaySlipForThisMonth', false);
      }
    } else {
      if (thisDay1 != '31') {
        pref.setBool('runPaySlipForThisMonth', false);
      }
    }

    timer = Timer.periodic(const Duration(milliseconds: 10), (Timer t) {
      if (mounted) {
        timeForNow = DateFormat('H:m a').format(DateTime.now());

        _timeNotifier.value = timeForNow;
        var now = DateTime.now();
        var thisDay = '';
        thisDay = now.day.toString();

        // if (thisDay == '26') {
        //   var count = pref.getInt('paySlipNotiCount');

        //   _notiCountNotifier.value = count.toString();
        // }

        if (thisMonth == "04" ||
            thisMonth == "06" ||
            thisMonth == "09" ||
            thisMonth == "11") {
          if (thisDay1 == '30') {
            var count = pref.getInt('paySlipNotiCount');

            _notiCountNotifier.value = count.toString();
          }
        } else if (thisMonth == "02") {
          if (thisDay1 == '28' || thisDay1 == '29') {
            var count = pref.getInt('paySlipNotiCount');

            _notiCountNotifier.value = count.toString();
          }
        } else {
          if (thisDay1 == '31') {
            var count = pref.getInt('paySlipNotiCount');

            _notiCountNotifier.value = count.toString();
          }
        }
      }
    });

    timer = Timer.periodic(const Duration(seconds: 15), (Timer t) {});
  }

  /// iOS/Android-compatible accurate position via stream.
  /// Collects readings for up to [timeout] and returns the best (lowest
  /// accuracy radius) one.  Returns early if [targetAccuracyMeters] is beaten.
  /// Using a stream avoids the iOS getCurrentPosition() timeout that forced
  /// the original code to use LocationAccuracy.medium (WiFi, ±100-500 m).
  Future<Position?> _getAccuratePosition({
    double targetAccuracyMeters = 50,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final completer = Completer<Position?>();
    Position? bestSoFar;

    final sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((pos) {
      if (bestSoFar == null || pos.accuracy < bestSoFar!.accuracy) {
        bestSoFar = pos;
      }
      if (pos.accuracy <= targetAccuracyMeters && !completer.isCompleted) {
        completer.complete(pos);
      }
    }, onError: (_) {
      if (!completer.isCompleted) completer.complete(bestSoFar);
    });

    Future.delayed(timeout, () {
      if (!completer.isCompleted) completer.complete(bestSoFar);
    });

    final result = await completer.future;
    await sub.cancel();
    return result;
  }

  _sendAttendance() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;

    if (checkInternet == false) {
      EasyLoading.dismiss();
      if (!mounted) return;
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

    await _syncToServer(att);

    setState(() {});
  }

  checkIsCheckIn() async {
    lastAttCheckDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tempAttendance =
        await attendanceDao.getTodayAttendance(lastAttCheckDate);

    _isCheckIn = pref.getBool('is_check_in');
    await loadData();

    setState(() {});
  }

  Future<Attendance?> _insertCheckIn() async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var shareComponent = ShareComponentClass();
    var deviceStatus = await shareComponent.readDeviceId();
    DateTime currentDateTime = DateTime.now();
    String check_in_datetime =
        DateUtil().getSqlDateTime(currentDateTime, 'yyyy-MM-dd HH:mm:ss');

    // Use _getAccuratePosition() so the GPS chip has time to get a real
    // satellite fix. LocationAccuracy.medium (WiFi/cell-tower) can be 100-500m
    // off. getLastKnownPosition() is never used — stale cached coordinates from
    // a previous session could be from a completely different place.
    Position? userPosition = await _getAccuratePosition();
    userPosition ??= Position(
      latitude: 0, longitude: 0, timestamp: DateTime.now(),
      accuracy: 0, altitude: 0, altitudeAccuracy: 0,
      heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0,
    );

    final String checkInMode = _pendingOutsideMode ? 'outside' : 'office';
    String checkInAddress = '';
    if (_pendingOutsideMode) {
      checkInAddress = await ReverseGeocode.fromLatLong(
          userPosition.latitude, userPosition.longitude);
    }

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
        userPosition.latitude,
        userPosition.longitude,
        0,
        0,
        address,
        '',
        deviceStatus.androidId,
        '',
        '',
        'default',
        '',
        '',
        work_mode: _pendingWorkMode,
        accuracy: userPosition.accuracy,
        check_in_mode: checkInMode,
        check_in_address: checkInAddress);

    return att;
  }

  Future<Attendance?> _insertCheckout() async {
    Attendance? attendance;
    var todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var tempAttendance =
        await attendanceDao.getTodayAttendanceAlreadyCheckIn(todayDate);
    checkInOutTime = DateFormat('H:m a').format(DateTime.now());

    Position? userPosition = await _getAccuratePosition();
    userPosition ??= Position(
      latitude: 0, longitude: 0, timestamp: DateTime.now(),
      accuracy: 0, altitude: 0, altitudeAccuracy: 0,
      heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0,
    );

    final String checkOutMode = _pendingOutsideMode ? 'outside' : 'office';
    String checkOutAddress = '';
    if (_pendingOutsideMode) {
      checkOutAddress = await ReverseGeocode.fromLatLong(
          userPosition.latitude, userPosition.longitude);
    }

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
          userPosition.latitude,
          userPosition.longitude,
          attendance.in_location,
          attendance.out_location,
          attendance.device_id,
          'default',
          attendance.write_date,
          attendance.att_type,
          '',
          '',
          id: attendance.id,
          work_mode: _pendingWorkMode,
          check_in_mode: attendance.check_in_mode,
          check_in_address: attendance.check_in_address,
          check_out_mode: checkOutMode,
          check_out_address: checkOutAddress);
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

    if (_isCheckIn!) {
      checkInResult = await attendanceApi.createAttendance(attendance, '');
    } else {
      checkInResult = await attendanceApi.checkOutAttendance(attendance, '');
    }


    if (checkInResult['result'] == 'fail') {
      var message;

      EasyLoading.dismiss();

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
          EasyLoading.dismiss();

          await Future.delayed(const Duration(seconds: 4));

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

    if (!mounted) return;
    toast = FToast();
    toast!.init(context); //Custom edit

    var status = checkInResult['attendanceMessage'];

    EasyLoading.dismiss();

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

      await _offerJustification(attendance, true);
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

      await _offerJustification(attendance, false);
    }
  }

  /// Shown when the office geofence check fails — lets the employee register
  /// the attendance as context.l10n.workFromOutside instead.
  Future<bool?> _showOutsideFallbackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.notInAllowedArea,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
            'You are outside the allowed office area.\n\nDo you want to register this attendance as context.l10n.workFromOutside? Your location and address will be recorded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.workFromOutside),
          ),
        ],
      ),
    );
  }

  /// Post check-in/out prompts:
  /// - outside mode → optional 'outside_location' justification
  /// - normal checkout → non-blocking early-leave snackbar action
  Future<void> _offerJustification(Attendance attendance, bool wasCheckIn) async {
    if (!mounted) return;
    final bool outside = wasCheckIn
        ? attendance.check_in_mode == 'outside'
        : attendance.check_out_mode == 'outside';
    if (outside) {
      await showJustificationDialog(context,
          type: 'outside_location',
          attendanceId: attendance.attendanceId,
          optional: true);
    } else if (!wasCheckIn) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Left early? You can add a justification.'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Add',
          onPressed: () {
            showJustificationDialog(context,
                type: 'early_leave', attendanceId: attendance.attendanceId);
          },
        ),
      ));
    }
  }

  void _onJustificationPush(RemoteMessage message) {
    if (message.data['type'] != 'attendance_justification') return;
    justificationRefreshTick.value++;
    final state = (message.data['state'] ?? 'updated').toString();
    toast?.showToast(
      child: Widgets().getInfoToast('Justification request $state'),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(),
            const SizedBox(height: 16),
            // RemoteModeCard(), // Added RemoteModeCard here
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(
                  horizontal: 16), // Added margin to match image
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.pleaseCheckInOut,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getTodayFormattedDate(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _timeNotifier,
                    builder: (_, value, __) => RichText(
                        text: TextSpan(
                      text: '$value',
                      style: const TextStyle(
                          fontSize: 15,
                          color: ColorObj.secondColor,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      try {
                        employee = await employeeDao.getSingleEmployeeById(uid!);

                        // Refresh settings BEFORE the dialog: geofence
                        // locations + the freshest mobile_work_mode
                        // (backend also returns it from attendance_setting).
                        EasyLoading.show();
                        await attendanceApi.getAttendanceSetting(employee!.employee_id!);
                        EasyLoading.dismiss();

                        final sp = await SharedPreferences.getInstance();
                        final settingMode =
                            sp.getString('mobile_work_mode_setting') ?? '';
                        final allowedMode = settingMode.isNotEmpty
                            ? settingMode
                            : (employee?.mobile_work_mode ?? 'office_only');

                        // Step 1: Work mode dialog — always shown; the
                        // Remote/Field/Outside options are gated by
                        // allowedMode (backend rejects violations anyway).
                        if (!mounted) return;
                        final selected = await _showWorkModeDialog(allowedMode);
                        if (selected == null) return; // user cancelled

                        // 'outside' = office attendance that skips the
                        // geofence; coordinates + address still captured.
                        final bool outsideMode = selected == 'outside';
                        final workMode = outsideMode ? 'office' : selected;

                        _pendingWorkMode = workMode;
                        _pendingOutsideMode = outsideMode;

                        // Step 2: local geofence check only for office mode
                        // (and never for outside)
                        if (workMode == 'office' && !outsideMode) {
                          EasyLoading.show();
                          AttendanceChecker checker = AttendanceChecker();
                          bool hasPermission = await checker.checkAttendancePermission();
                          EasyLoading.dismiss();

                          if (!hasPermission) {
                            if (!mounted) return;
                            if (allowedMode == 'office_only') {
                              // Outside is not permitted for this employee —
                              // plain rejection, no fallback offer.
                              FToast ftoast = FToast()..init(context);
                              ftoast.showToast(
                                child: Widgets().getErrorToast(
                                    context.l10n.notInAllowedAreaMsg),
                                gravity: ToastGravity.BOTTOM,
                                toastDuration: const Duration(seconds: 2),
                              );
                              return;
                            }
                            // Not in allowed area — offer registering as
                            // Work From Outside instead of a dead end.
                            final useOutside =
                                await _showOutsideFallbackDialog();
                            if (useOutside != true) return;
                            _pendingOutsideMode = true;
                          }
                        }

                        // Step 3: Biometric authentication
                        if (!mounted) return;
                        final BiometricService biometricService = BiometricService();
                        bool verified = await biometricService.authenticate();

                        if (!verified) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.authenticationFailed)),
                          );
                          return;
                        }

                        if (!mounted) return;
                        showConfirmationDialog(context);

                      } catch (e) {
                        EasyLoading.dismiss();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              duration: const Duration(seconds: 4),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCheckIn == true ? Colors.green : Colors.red,
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.registerYourPresence,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    context.l10n.yourWork,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            //SizedBox(height: 10),
            _buildAttendanceSection(),
          ],
        ),
      ),
      // Bottom Navigation Bar (if needed)
    );
  }

  void confirmDialog(
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
              //  backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
                        child: Material(
                          color: ColorObj.mainColor,
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(context.l10n.confirmation,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 23,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                // margin: EdgeInsets.only(top: 3),
                                child: const Icon(
                                  Icons.warning,
                                  size: 31,
                                  color: ColorObj.mainColor,
                                ),
                              ),
                              Flexible(
                                child: Container(
                                    margin: const EdgeInsets.only(left: 10, top: 10),
                                    child: Text(
                                      context.l10n.exitAppConfirm,
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 15),
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  context.l10n.cancel,
                                  style: TextStyle(
                                    color: ColorObj.mainColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 28,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorObj.mainColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 36, vertical: 10),
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                      )),
                                  onPressed: () {
                                    SystemNavigator.pop();
                                  },
                                  child: Text(
                                    context.l10n.ok,
                                    style: TextStyle(fontSize: 13),
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
      },
    );
  }

  /// Shows the work mode selector based on what the employee is allowed to use.
  /// Returns 'office', 'remote', 'field', 'outside' (office attendance that
  /// skips the geofence) or null if cancelled.
  Future<String?> _showWorkModeDialog(String allowedMode) async {
    // Build list of available options based on employee's allowed mode
    final options = <Map<String, dynamic>>[
      {'value': 'office', 'label': context.l10n.inOffice, 'icon': Icons.business, 'color': Colors.green},
    ];
    if (allowedMode == 'remote' || allowedMode == 'all') {
      options.add({'value': 'remote', 'label': context.l10n.remoteWfh, 'icon': Icons.home_work, 'color': Colors.blue});
    }
    if (allowedMode == 'field' || allowedMode == 'all') {
      options.add({'value': 'field', 'label': context.l10n.fieldWork, 'icon': Icons.directions_car, 'color': Colors.orange});
    }
    // Work From Outside — permitted for every mode except office_only
    // (backend v19.0.3.4 rejects mode='outside' for office_only accounts).
    if (allowedMode != 'office_only') {
      options.add({'value': 'outside', 'label': context.l10n.workFromOutside, 'icon': Icons.location_off, 'color': Colors.purple});
    }

    // Only one permitted option (office_only) — skip the dialog entirely,
    // restoring the old zero-tap behavior for restricted employees.
    if (options.length == 1) {
      return Future.value('office');
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.selectWorkMode, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(ctx, opt['value'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: opt['color'] as Color, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(opt['icon'] as IconData, color: opt['color'] as Color),
                    const SizedBox(width: 12),
                    Text(opt['label'] as String,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                            color: opt['color'] as Color)),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    var textValue = '';
    if (_isCheckIn == true) {
      textValue = context.l10n.checkIn;
    } else {
      textValue = context.l10n.checkOut;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: const Color.fromARGB(255, 110, 110, 110)
                        .withOpacity(0.1), // Optional color overlay
                  ),
                ),
              ),
              Center(
                  child: Container(
                width: 100.0, // width of the circle
                height: 100.0, // height of the circle
                decoration: const BoxDecoration(
                  color: Colors.white, // background color
                  shape: BoxShape.circle, // make the container circular
                ),
                child: InkWell(
                  onTap: () async {
                    EasyLoading.show();

                    await _sendAttendance();
                    await checkIsCheckIn();
                    EasyLoading.dismiss();
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Proceed with confirmation
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.locationPin,
                        color: _isCheckIn == true ? Colors.green : Colors.red,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        textValue,
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                _isCheckIn == true ? Colors.green : Colors.red),
                      )
                    ],
                  ),
                ),
              )),
            ],
          );
        });
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: ColorObj.mainColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        // Avoid notch issues
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmployeeDetailScreen()));
              },
              child: Row(
                children: [
                  bytes != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              //  NetworkImage(
                              //     "https://via.placeholder.com/150"), // Replace with your image
                              MemoryImage(bytes!),
                        )
                      : const CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              AssetImage('assets/imgs/default_avator.png'),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n
                              .goodMorning(employee?.employee_name ?? ''),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          context.l10n.goodDayMessage,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => LocaleController.toggle(context),
                    child: const Icon(Icons.language, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.notifications, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Disable GridView scrolling
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExpenseListPage()));
                },
                child: _buildAttendanceItem('assets/imgs/6.png', context.l10n.paymentRequest,
                    expenseCount.toString(), Colors.yellow[100]!, 35, 35),
              ),
              GestureDetector(
                  onTap: () async {
                    passwordController.clear();
                    confirmPwController.clear();
                    confirmPwController.clear();

                    password = pref.getString('password');

                    if (password == null || password == '') {
                      createPassword = true;
                      confirmPassword = true;
                    } else {
                      createPassword = false;
                    }

                    bool isChecked = false;

                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return Dialog(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromARGB(255, 221, 240,
                                            255), // Change color of the shadow
                                        blurRadius: 1.0,
                                        spreadRadius: 1.0,
                                        offset: Offset(2.0, 2.0))
                                  ],
                                ),
                                padding: const EdgeInsets.all(25),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: createPassword
                                    ? MediaQuery.of(context).size.height * 0.4
                                    : MediaQuery.of(context).size.height * 0.31,
                                child: Column(
                                  children: <Widget>[
                                    // SizedBox(height: 10.0),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      child: Center(
                                          child: Text(
                                        createPassword
                                            ? context.l10n.createPasswordTitle
                                            : context.l10n.enterPasswordToAccess,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                    ),
                                    // SizedBox(height: 48.0),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      alignment: Alignment.bottomCenter,
                                      child: TextFormField(
                                        controller: passwordController,
                                        obscureText:
                                            isvisible == false ? true : false,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofocus: false,
                                        cursorColor: Colors.grey[600],
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isvisible = !isvisible;
                                                });
                                              },
                                              icon: isvisible == false
                                                  ? Icon(
                                                      Icons.visibility_off,
                                                      color: Colors.grey[400],
                                                    )
                                                  : Icon(
                                                      Icons.visibility,
                                                      color: Colors.grey[800],
                                                    )),
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255, 252, 251, 251),
                                          enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color:
                                                    Colors.grey), //<-- SEE HERE
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 1,
                                                color:
                                                    Colors.grey), //<-- SEE HERE
                                          ),
                                          hintText: context.l10n.password,
                                          contentPadding: const EdgeInsets.fromLTRB(
                                              20.0, 12.0, 20.0, 12.0),
                                        ),
                                      ),
                                    ),
                                    // createPassword
                                    //     ? SizedBox(height: 20.0)
                                    //     : SizedBox(height: 5.0),
                                    createPassword
                                        ? Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            alignment: Alignment.bottomCenter,
                                            child: TextFormField(
                                              controller: confirmPwController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              autofocus: false,
                                              obscureText: isVisiable1 == false
                                                  ? true
                                                  : false,
                                              cursorColor: Colors.grey[600],
                                              decoration: InputDecoration(
                                                suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isVisiable1 =
                                                            !isVisiable1;
                                                      });
                                                    },
                                                    icon: isVisiable1 == false
                                                        ? Icon(
                                                            Icons
                                                                .visibility_off,
                                                            color: Colors
                                                                .grey[400],
                                                          )
                                                        : Icon(
                                                            Icons.visibility,
                                                            color: Colors
                                                                .grey[800],
                                                          )),
                                                filled: true,
                                                fillColor: const Color.fromARGB(
                                                    255, 252, 251, 251),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors
                                                          .grey), //<-- SEE HERE
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors
                                                          .grey), //<-- SEE HERE
                                                ),
                                                hintText: context.l10n.confirmPassword,
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        20.0, 12.0, 20.0, 12.0),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    //SizedBox(height: 24.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: const <Widget>[],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.09,
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            !createPassword
                                                ? InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                              return Dialog(
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              221,
                                                                              240,
                                                                              255), // Change color of the shadow
                                                                          blurRadius:
                                                                              1.0,
                                                                          spreadRadius:
                                                                              1.0,
                                                                          offset: Offset(
                                                                              2.0,
                                                                              2.0))
                                                                    ],
                                                                  ),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                              25),
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.8,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.49,
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      // SizedBox(
                                                                      //     height:
                                                                      //         10.0),
                                                                      SizedBox(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.04,
                                                                        child: Center(
                                                                            child: Text(
                                                                          context.l10n.changePassword,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            // fontWeight:
                                                                            //     FontWeight
                                                                            //         .bold,
                                                                          ),
                                                                        )),
                                                                      ),
                                                                      // SizedBox(
                                                                      //     height:
                                                                      //         48.0),
                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.1,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              currentPwController,
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          autofocus:
                                                                              false,
                                                                          obscureText: isVisiable2 == false
                                                                              ? true
                                                                              : false,
                                                                          cursorColor:
                                                                              Colors.grey[600],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            suffixIcon: IconButton(
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    isVisiable2 = !isVisiable2;
                                                                                  });
                                                                                },
                                                                                icon: isVisiable2 == false
                                                                                    ? Icon(
                                                                                        Icons.visibility_off,
                                                                                        color: Colors.grey[400],
                                                                                      )
                                                                                    : Icon(
                                                                                        Icons.visibility,
                                                                                        color: Colors.grey[800],
                                                                                      )),
                                                                            filled:
                                                                                true,
                                                                            fillColor: const Color.fromARGB(
                                                                                255,
                                                                                252,
                                                                                251,
                                                                                251),
                                                                            enabledBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            focusedBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            hintText:
                                                                                context.l10n.currentPassword,
                                                                            contentPadding: const EdgeInsets.fromLTRB(
                                                                                20.0,
                                                                                12.0,
                                                                                20.0,
                                                                                12.0),
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.1,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              passwordController,
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          autofocus:
                                                                              false,
                                                                          obscureText: isVisiable1 == false
                                                                              ? true
                                                                              : false,
                                                                          cursorColor:
                                                                              Colors.grey[600],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            suffixIcon: IconButton(
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    isVisiable1 = !isVisiable1;
                                                                                  });
                                                                                },
                                                                                icon: isVisiable1 == false
                                                                                    ? Icon(
                                                                                        Icons.visibility_off,
                                                                                        color: Colors.grey[400],
                                                                                      )
                                                                                    : Icon(
                                                                                        Icons.visibility,
                                                                                        color: Colors.grey[800],
                                                                                      )),
                                                                            filled:
                                                                                true,
                                                                            fillColor: const Color.fromARGB(
                                                                                255,
                                                                                252,
                                                                                251,
                                                                                251),
                                                                            enabledBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            focusedBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            hintText:
                                                                                context.l10n.newPassword,
                                                                            contentPadding: const EdgeInsets.fromLTRB(
                                                                                20.0,
                                                                                12.0,
                                                                                20.0,
                                                                                12.0),
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.1,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              confirmPwController,
                                                                          keyboardType:
                                                                              TextInputType.emailAddress,
                                                                          autofocus:
                                                                              false,
                                                                          obscureText: isvisible == false
                                                                              ? true
                                                                              : false,
                                                                          cursorColor:
                                                                              Colors.grey[600],
                                                                          decoration:
                                                                              InputDecoration(
                                                                            suffixIcon: IconButton(
                                                                                onPressed: () {
                                                                                  setState(() {
                                                                                    isvisible = !isvisible;
                                                                                  });
                                                                                },
                                                                                icon: isvisible == false
                                                                                    ? Icon(
                                                                                        Icons.visibility_off,
                                                                                        color: Colors.grey[400],
                                                                                      )
                                                                                    : Icon(
                                                                                        Icons.visibility,
                                                                                        color: Colors.grey[800],
                                                                                      )),
                                                                            filled:
                                                                                true,
                                                                            fillColor: const Color.fromARGB(
                                                                                255,
                                                                                252,
                                                                                251,
                                                                                251),
                                                                            enabledBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            focusedBorder:
                                                                                const OutlineInputBorder(
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey), //<-- SEE HERE
                                                                            ),
                                                                            hintText:
                                                                                context.l10n.confirmPassword,
                                                                            contentPadding: const EdgeInsets.fromLTRB(
                                                                                20.0,
                                                                                12.0,
                                                                                20.0,
                                                                                12.0),
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      Container(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.08,
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text(
                                                                                  context.l10n.cancel,
                                                                                  style: TextStyle(fontFamily: 'Regular', fontSize: 16, color: Colors.red),
                                                                                )),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () async {
                                                                                toast = FToast();
                                                                                toast!.init(context);
                                                                                pref = await SharedPreferences.getInstance();
                                                                                String cPw = await pref!.getString("password");

                                                                                if (currentPwController.text.toString() == cPw) {
                                                                                  if (passwordController.text.toString() != '' && confirmPwController.text.toString() != '') {
                                                                                    if (passwordController.text.toString() == confirmPwController.text.toString()) {
                                                                                      await pref!.setString("password", passwordController.text.toString());

                                                                                      if (!mounted) return;
                                                                                      Navigator.of(context).pop();

                                                                                      toast!.showToast(child: Widgets().getSuccessToast(context.l10n.passwordChanged));
                                                                                    } else {
                                                                                      if (!mounted) return;
                                                                                      Navigator.of(context).pop();

                                                                                      toast!.showToast(child: Widgets().getWarningToast(context.l10n.passwordDoesNotMatch));
                                                                                    }
                                                                                  } else {
                                                                                    //blank new andconfirm pw blank
                                                                                    if (!mounted) return;
                                                                                    Navigator.of(context).pop();

                                                                                    toast!.showToast(
                                                                                      child: Widgets().getWarningToast(context.l10n.passwordBlank),
                                                                                      toastDuration: const Duration(seconds: 3),
                                                                                    );
                                                                                  }
                                                                                } else {
                                                                                  if (!mounted) return;
                                                                                  Navigator.of(context).pop();
                                                                                  toast!.showToast(child: Widgets().getWarningToast(context.l10n.currentPasswordIncorrect));
                                                                                }

                                                                                passwordController.clear();
                                                                                confirmPwController.clear();
                                                                                currentPwController.clear();
                                                                              },
                                                                              child: Text(
                                                                                context.l10n.ok,
                                                                                style: TextStyle(fontFamily: 'Regular', fontSize: 16, color: ColorObj.mainColor),
                                                                              ),
                                                                            ),
                                                                            // const SizedBox(
                                                                            //   width:
                                                                            //       10,
                                                                            // ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          });
                                                    },
                                                    child: Text(
                                                      context.l10n.change,
                                                      style: TextStyle(
                                                          fontFamily: 'Regular',
                                                          fontSize: 16,
                                                          color: ColorObj
                                                              .greyColor7),
                                                    ))
                                                : const Text(''),
                                            Container(
                                              // color: Colors.grey,
                                              // height: MediaQuery.of(context)
                                              //         .size
                                              //         .height *
                                              //     0.09,
                                              // alignment: Alignment.bottomCenter,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  // const SizedBox(
                                                  //   width: 10,
                                                  // ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        context.l10n.cancel,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Regular',
                                                            fontSize: 16,
                                                            color: Colors.red),
                                                      )),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      toast = FToast();
                                                      toast!.init(context);
                                                      pref =
                                                          await SharedPreferences
                                                              .getInstance();

                                                      if (createPassword) {
                                                        if (passwordController
                                                                .text
                                                                .toString() !=
                                                            confirmPwController
                                                                .text
                                                                .toString()) {
                                                          toast!.showToast(
                                                            child: Widgets()
                                                                .getWarningToast(
                                                                    context.l10n.passwordMismatch),
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            toastDuration:
                                                                const Duration(
                                                                    seconds: 3),
                                                          );
                                                          if (!mounted) return;
                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          await pref.setString(
                                                              'password',
                                                              passwordController
                                                                  .text
                                                                  .toString());
                                                          if (!mounted) return;
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      } else {
                                                        var pw = await pref
                                                            .getString(
                                                                'password');
                                                        if ((passwordController
                                                                .text
                                                                .toString() ==
                                                            pw)) {
                                                          if (!mounted) return;
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const PaySlipListScreen()));
                                                        } else {
                                                          toast!.showToast(
                                                            child: Widgets()
                                                                .getWarningToast(
                                                                    context.l10n.invalidPassword),
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            toastDuration:
                                                                const Duration(
                                                                    seconds: 3),
                                                          );
                                                          if (!mounted) return;
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      createPassword
                                                          ? context.l10n.create
                                                          : context.l10n.submit,
                                                      style: const TextStyle(
                                                          fontFamily: 'Regular',
                                                          fontSize: 16,
                                                          color: ColorObj
                                                              .mainColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                        });
                  },
                  child: Card(
                    color: Colors.purple[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/slip2.png',
                            width: 40,
                            height: 40,
                          ),
                          Text(context.l10n.payslip, style: TextStyle(fontSize: 12)),
                          ValueListenableBuilder(
                            valueListenable: _paySlipCountNotifier,
                            builder: (_, value, __) => RichText(
                                text: TextSpan(
                              text: '$value',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            )),
                          ),
                          //Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AttendanceScreen()));
                },
                child: _buildAttendanceItem('assets/imgs/5.png', context.l10n.attendance,
                    attendanceCount.toString(), Colors.red[100]!, 42, 42),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HrAdminScreen()));
                },
                child: _buildIconItem(Icons.badge_outlined, context.l10n.hrAdmin,
                    context.l10n.requestsAndLeave, Colors.teal[50]!),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ApprovalsInboxScreen()));
                },
                child: _buildIconItem(Icons.pending_actions_outlined,
                    context.l10n.approvals, context.l10n.inbox, Colors.orange[50]!),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyLoansScreen()));
                },
                child: _buildIconItem(Icons.account_balance_wallet_outlined,
                    context.l10n.loans, context.l10n.myLoans, Colors.indigo[50]!),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DiscussScreen()));
                },
                child: _buildDiscussItem(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconItem(
      IconData icon, String title, String value, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ColorObj.mainColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: ColorObj.mainColor, size: 24),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussItem() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ColorObj.mainColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: ColorObj.mainColor, size: 24),
            ),
            const SizedBox(height: 4),
            Text(context.l10n.discuss, style: TextStyle(fontSize: 12)),
            Text(context.l10n.chat, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceItem(String image, String title, String value,
      Color color, double width, double height) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: width,
              height: height,
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.todaysSummary,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Add your summary content here
        ],
      ),
    );
  }
}
