import 'dart:async';
//import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talent_hr/presentation/screens/base.account/login.dart';
import 'package:talent_hr/presentation/screens/base.account/reject_screen.dart';
import 'package:talent_hr/presentation/screens/base.account/waiting_screen.dart';
import 'package:talent_hr/presentation/screens/dashboard/dashboard_main.dart';
// import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/login_api.dart';
import '../../../data/helper/constant.dart';
import '../../../utility/share/share_component.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';
import 'package:talent_hr/app/locale_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // var ;
  late BuildContext _scaffoldCtx;
  Timer? timer;
  var deviceState = '';
  var loginApi = loginAPI();
  var pref;
  FToast? toast;
  StreamSubscription? subscription;
  bool hasConnection = true;
  var waitingStage;

  @override
  void initState() {
    // TODO: implement initState
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
    loadData();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();
    await pref.setBool(
        'welcomePage', true); //for internet restore and checkactivation
   
    await gotoNext();
  }

  gotoNext() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (checkInternet == false) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }

    timer = Timer(const Duration(milliseconds: 1), () async {
      String? token = await pref.getString('jwt_token');

      waitingStage = await pref.getString('waitingStage');

      if (waitingStage == null || waitingStage == '') {
        await pref.setString('waitingStage', 'false');
      }

      if (token.toString() != "null" && token != null) {
        if (waitingStage == 'true') {
          dispose();
          if (!mounted) return;
          Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return const WaitingScreen();
          }), (route) => false);
        } else {
          if (checkInternet == false) {
            if (!mounted) return;
            showDialog(context: context, builder: (_) => const CustomEventDialog());
            return;
          }
          checkDeviceActivation();
        }
      } else {
        if (!mounted) return;
        Navigator.of(_scaffoldCtx).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
          return const LoginScreen();
        }), (route) => false);
      }
    });
    await pref.setBool(
        'welcomePage', false); //for internet restore and checkactivation
  }

  

  @override
  void dispose() {
    timer?.cancel();
    //subscription?.cancel();
    super.dispose();
  }



  Future<void> checkDeviceActivation() async {
   
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
    //SizeConfig().init(context);
    _scaffoldCtx = context;
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Image(
                width: 70,
                height: 70,
                image: AssetImage('assets/logos/ic_hrms.jpg'),
              ),
            ),
           
          ],
        ),
      ),
    ));
  }
}
