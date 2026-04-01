import 'dart:async';
import 'package:device_info/device_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent_hr/data/api/login_api.dart';
import 'package:talent_hr/presentation/screens/base.account/waiting_screen.dart';
import 'package:talent_hr/utility/style/theme.dart' as Style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/config.dart';
import '../../../data/helper/constant.dart';
import '../../../utility/share/share_component.dart';
import '../../../utility/utils/alertText.dart';
import '../../widgets/custom_event_dialog.dart';
import '../../widgets/widgets.dart';

import '../dashboard/dashboard_main.dart';

class LoginScreen extends StatefulWidget {
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // SharedPreferences? _prefs;
  bool _obscureText = true;
  bool _isInvalid = false;
  String _versionNo = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _focusNode = FocusNode();
  FocusNode _urlF = FocusNode();
  FocusNode _nameF = FocusNode();
  FocusNode _passF = FocusNode();
  var _database = '';
  List<DropdownMenuItem<String>> _dbMenuList = [];
  FToast? toast;
  bool? isLogin;
  bool _showLoginForm = false;
  bool? loginned = false;
  var loginApi = loginAPI();
  late Timer timer;
  var deviceState = '';
  var _dbList = <Map<String, dynamic>>[];
  var _listDbSuccessful = false;
  late DeviceInfoPlugin deviceInfoPlugin;
  late AndroidDeviceInfo androidDeviceInfo;
  var pref;
  StreamSubscription? subscription;
  bool hasConnection = true;

  bool enteredUrl = false;

  bool showDatabaseDropdown = false;

  bool ckeckedUrl = false;
  var url;
  var deviceStatus;

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
    url = Config.url;
    urlController.text = url;
    await pref.setString('url', url);
    var username = await pref.getString('username');

    var userPw = await pref.getString('user_pw');
    if (username != null && userPw != null) {
      usernameController.text = username;
      passwordController.text = userPw;
    }
  
  
  
  }

  void dispose() {
    super.dispose();
    timer.cancel();
  }

 
  Future<void> login() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => CustomEventDialog());
      return;
    }

   
    var userId;

    var loginResult;

    EasyLoading.show(status: 'signing in...........');

    loginResult = await loginApi.login(
      usernameController.text.toString(),
      passwordController.text.toString(),
      deviceStatus.id,
      deviceStatus.androidId.toString(),
      deviceStatus.device,
      deviceStatus.model,
    );

    EasyLoading.dismiss();

    print('loginResult----------$loginResult');
    if (loginResult == 'success') {
      pref.setString('username', usernameController.text.toString());
      pref.setString('user_pw', passwordController.text.toString());
      toast!.showToast(
        child: Widgets().getSuccessToast(MessageAndAlertText.loginSuccessful),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
      );
      var loginned = await pref.getBool('loginned');

      if (loginned != null && loginned == true) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        pref.setString('waitingStage', 'true');
        pref.setBool(Constant.WAITING_APPROVE, true);
        pref.setBool(Constant.IS_APPROVED, false);
        pref.setBool(Constant.IS_LOGIN, false);
        timer = Timer(const Duration(milliseconds: 1), () async {
          timer.cancel();

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => WaitingScreen()));
        });
      }
    } else {
      toast!.showToast(
        child: Widgets().getErrorToast(loginResult),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );
    }
  }

  Widget build(BuildContext context) {
    // SizeConfig().init(context);
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Style.ColorObj.layoutColor,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 85,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Image(
                width: 80,
                height: 80,
                //  color: Style.ColorObj.loginBackgroundColor,
                image: AssetImage('assets/logos/ic_hrms.jpg'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Welcome",
              style: TextStyle(
                  color: Style.ColorObj.loginBackgroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
            SizedBox(
              height: 15,
            ),
           
            Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                margin: EdgeInsets.all(30.0),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                    
                      showDatabaseDropdown
                          ? Container(
                              margin: EdgeInsets.only(bottom: 12),
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
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(MdiIcons.database),
                                ),
                                hint: Text(
                                  'Select Database',
                                  style: TextStyle(fontSize: 15),
                                ),
                                value: _database,
                                onChanged: (newValue) async {
                                  print('onChange--------$newValue');
                                  _database = newValue.toString();
                                  await pref!.setString('database', _database);
                                  enteredUrl = false;
                                  setState(() {});
                                },
                              ),
                            )
                          : Text(''),
                      Container(
                        height: _isInvalid ? 70 : 50,
                        child: TextFormField(
                          focusNode: _nameF,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                          controller: usernameController,
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'username',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(bottom: 25)),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: _isInvalid ? 70 : 50,
                        child: TextFormField(
                          focusNode: _passF,
                          cursorColor: Colors.grey,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          controller: passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'password',
                            suffixIcon: IconButton(
                              icon: _obscureText
                                  ? Icon(Icons.remove_red_eye)
                                  : FaIcon(
                                      FontAwesomeIcons.solidEyeSlash,
                                      size: 18,
                                    ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(),
                            /*contentPadding: EdgeInsets.only(
                                                                    bottom: 25
                                                                )*/
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                   

                      InkWell(
                        onTap: () async{
                           print('onPressed--------------');

                          // enteredUrl = true;
                          // url = urlController.text.toString();
                          await pref.setString('url', url);
                          //showDatabaseDropdown = true;

                          await pref!.setString('database',
                              'scofield0007-hr-mobile-app-main-12633087');

                          if (_formKey.currentState!.validate()) {
                            print('_formKey.currentState------------');
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
                        padding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                        decoration: BoxDecoration(
                            gradient:
                                LinearGradient(colors: [Color.fromARGB(255, 0, 117, 133),Colors.cyan, Color.fromARGB(255, 0, 117, 133),Color.fromARGB(255, 101, 192, 210),Color.fromARGB(255, 0, 117, 133)]),
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Text(
                          'Start Your ID',
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
