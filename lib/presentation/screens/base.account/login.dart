import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent_hr/data/api/login_api.dart';
import 'package:talent_hr/presentation/screens/base.account/waiting_screen.dart';
import 'package:talent_hr/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/config.dart';
import '../../../data/helper/constant.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/utils/alertText.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';

import '../dashboard/dashboard_main.dart';
import 'package:talent_hr/app/locale_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // SharedPreferences? _prefs;
  bool _obscureText = true;
  bool _isInvalid = false;
  final String _versionNo = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _focusNode = FocusNode();
  final FocusNode _urlF = FocusNode();
  final FocusNode _nameF = FocusNode();
  final FocusNode _passF = FocusNode();
  var _database = '';
  final List<DropdownMenuItem<String>> _dbMenuList = [];
  FToast? toast;
  bool? isLogin;
  final bool _showLoginForm = false;
  bool? loginned = false;
  var loginApi = loginAPI();
  Timer? timer;
  var deviceState = '';
  final _dbList = <Map<String, dynamic>>[];
  final _listDbSuccessful = false;
  var pref;
  StreamSubscription? subscription;
  bool hasConnection = true;

  bool enteredUrl = false;

  bool showDatabaseDropdown = false;

  bool ckeckedUrl = false;
  String url = Config.url;
  AppDeviceInfo? deviceStatus;

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

    initiate();
  }

  initiate() async {
    pref = await SharedPreferences.getInstance();
   
    var shareComponent = ShareComponentClass();
    deviceStatus = await shareComponent.readDeviceId();
    url = pref.getString('url') ?? Config.url;
    urlController.text = url;
    await pref.setString('url', url);
    var username = await pref.getString('username');

    var userPw = await pref.getString('user_pw');
    if (username != null && userPw != null) {
      usernameController.text = username;
      passwordController.text = userPw;
    }
  
  
  
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _saveFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null) return;

      final urlLink = pref.getString('url') ?? '';
      final uid = pref.getInt('uid') ?? 0;
      final cookie = pref.getString('header_cookie') ?? '';
      final database = pref.getString('database') ?? '';

      await http.post(
        Uri.parse('${urlLink}api/save/fcm_token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'cookie': cookie,
          'db_name': database,
        },
        body: json.encode({'employee_id': uid, 'token': token}),
      );

      // Keep token fresh if Firebase rotates it
      messaging.onTokenRefresh.listen((newToken) async {
        final updatedCookie = pref.getString('header_cookie') ?? '';
        final updatedDb = pref.getString('database') ?? '';
        final updatedUid = pref.getInt('uid') ?? 0;
        await http.post(
          Uri.parse('${urlLink}api/save/fcm_token'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'cookie': updatedCookie,
            'db_name': updatedDb,
          },
          body: json.encode({'employee_id': updatedUid, 'token': newToken}),
        );
      });
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }
  }

  Future<void> login() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }

   
    var userId;

    var loginResult;

    if (deviceStatus == null) {
      toast!.showToast(
        child: Widgets().getErrorToast(context.l10n.deviceInfoLoading),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      return;
    }

    EasyLoading.show(status: context.l10n.signingIn);

    loginResult = await loginApi.login(
      usernameController.text.toString(),
      passwordController.text.toString(),
      deviceStatus!.id,
      deviceStatus!.androidId,
      deviceStatus!.device,
      deviceStatus!.model,
    );

    EasyLoading.dismiss();

    if (loginResult == 'success') {
      pref.setString('username', usernameController.text.toString());
      pref.setString('user_pw', passwordController.text.toString());
      toast!.showToast(
        child: Widgets().getSuccessToast(MessageAndAlertText.loginSuccessful),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 2),
      );
      _saveFcmToken(); // fire-and-forget — don't await, never blocks login
      var loginned = await pref.getBool('loginned');

      if (!mounted) return;
      if (loginned != null && loginned == true) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        pref.setString('waitingStage', 'true');
        pref.setBool(Constant.WAITING_APPROVE, true);
        pref.setBool(Constant.IS_APPROVED, false);
        pref.setBool(Constant.IS_LOGIN, false);
        timer = Timer(const Duration(milliseconds: 1), () async {
          timer?.cancel();

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const WaitingScreen()));
        });
      }
    } else {
      toast!.showToast(
        child: Widgets().getErrorToast(loginResult),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // SizeConfig().init(context);
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: style.ColorObj.layoutColor,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 85,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Image(
                width: 80,
                height: 80,
                //  color: style.ColorObj.loginBackgroundColor,
                image: AssetImage('assets/logos/ic_hrms.jpg'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              context.l10n.welcome,
              style: TextStyle(
                  color: style.ColorObj.loginBackgroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
            const SizedBox(
              height: 15,
            ),
           
            Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                margin: const EdgeInsets.all(30.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                    
                      showDatabaseDropdown
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              height: 55,
                              child: DropdownButtonFormField(
                                items: [
                                  for (int i = 0; i < _dbList.length; i++)
                                    DropdownMenuItem<String>(
                                      // value: '${_dbList[i]['value']}',
                                      value: _dbList[i]['value'],
                                      child: Text(
                                        '${_dbList[i]['value']}',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[800]),
                                      ),
                                    ),
                                ],
                                isExpanded: true,
                                isDense: true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(MdiIcons.database),
                                ),
                                hint: Text(
                                  context.l10n.selectDatabase,
                                  style: TextStyle(fontSize: 15),
                                ),
                                value: _database,
                                onChanged: (newValue) async {
                                  _database = newValue.toString();
                                  await pref!.setString('database', _database);
                                  enteredUrl = false;
                                  setState(() {});
                                },
                              ),
                            )
                          : const Text(''),
                      SizedBox(
                        height: _isInvalid ? 70 : 50,
                        child: TextFormField(
                          focusNode: _nameF,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.l10n.pleaseEnterUsername;
                            }
                            return null;
                          },
                          controller: usernameController,
                          cursorColor: Colors.grey,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'username',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(bottom: 25)),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        height: _isInvalid ? 70 : 50,
                        child: TextFormField(
                          focusNode: _passF,
                          textCapitalization: TextCapitalization.none,
                          cursorColor: Colors.grey,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.visiblePassword,
                          smartDashesType: SmartDashesType.disabled,
                          smartQuotesType: SmartQuotesType.disabled,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.l10n.pleaseEnterPassword;
                            }
                            return null;
                          },
                          controller: passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            hintText: 'password',
                            suffixIcon: IconButton(
                              icon: _obscureText
                                  ? const Icon(Icons.remove_red_eye)
                                  : const FaIcon(
                                      FontAwesomeIcons.solidEyeSlash,
                                      size: 18,
                                    ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                            /*contentPadding: EdgeInsets.only(
                                                                    bottom: 25
                                                                )*/
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                   

                      InkWell(
                        onTap: () async{

                          // enteredUrl = true;
                          // url = urlController.text.toString();
                          final loginUrl = url.isNotEmpty
                              ? url
                              : (pref.getString('url') ?? Config.url);
                          await pref.setString('url', loginUrl);
                          //showDatabaseDropdown = true;

                          await pref!.setString('database',
                              'scofield0007-hr-mobile-app-main-12633087');

                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isInvalid = false;
                            });
                            login();
                          } else {
                            setState(() {
                              _isInvalid = true;
                            });
                          }
                        },
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                        decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(colors: [Color.fromARGB(255, 0, 117, 133),Colors.cyan, Color.fromARGB(255, 0, 117, 133),Color.fromARGB(255, 101, 192, 210),Color.fromARGB(255, 0, 117, 133)]),
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Text(
                          context.l10n.startYourId,
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                      ),
                  
                   
                    ],
                  ),
                ),
              ),
            ),
           
            // ))
          ],
        ),
      )),
    ));
  }
}
