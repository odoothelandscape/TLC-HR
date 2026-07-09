import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent_hr/data/api/employee_api.dart';
import 'package:talent_hr/utility/style/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/employee/employee.dart';
import '../../widgets/custom_event_dialog.dart';
import '../dashboard/dashboard_main.dart';
import 'package:talent_hr/app/locale_controller.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({super.key});

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  var pref;
  int? userId;
  var userLevel;
  Uint8List? bytes;
  var employeeDao = EmployeeDao();
  Employee? employee;
  var empApi = EmployeeAPI();
  var password;
  bool createPassword = false;
  bool fetchEmpUpdateData = false;
  var uid;

  @override
  void initState() {
    super.initState();
    // for (int i = 0; i < menuActive.length; i++) {
    //   menuActive[i] = false;
    // }
    // menuActive[1] = true;
    loadData();
  }

  loadData() async {
    pref = await SharedPreferences.getInstance();

    uid = await pref.getInt('uid');
    employee = await employeeDao.getSingleEmployeeById(uid);

    userId = await pref.getInt('uid');
    userLevel = await pref.getString('user_level');

    password = await pref.getString('password');
    if (password == null || password == '') {
      createPassword = true;
    }

    if (employee!.avatar != '') {
      bytes = base64.decode("${employee!.avatar}");
    } else {
      bytes = null;
    }

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return const HomeScreen();
        }), (r) {
          return false;
        });
        // Navigator.pop(context);

        return false;
      },
      child: Scaffold(
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  leading: InkWell(
                  onTap: () {
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return const HomeScreen();
                    }));
                  },
                  child: const Icon(Icons.home)),
                  backgroundColor: ColorObj.mainColor,
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            employee != null
                                ? employee!.employee_name.toString()
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            )),
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
                              EasyLoading.show(
                                  status: context.l10n.fetchingData);
                              var employeeApi = EmployeeAPI();
                              await employeeApi.getEmployeeList();
                              employee =
                                  await employeeDao.getSingleEmployeeById(uid);

                              EasyLoading.dismiss();
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 3, right: 5),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.green,
                                size: 25,
                              ),
                            ))
                      ],
                    ),
                    background: bytes != null
                        ? Image.memory(bytes!, fit: BoxFit.cover)
                        : const Image(
                            image: AssetImage('assets/imgs/default_avator.png'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ];
            },
            body: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: ListTile(
                      dense: true,

                      visualDensity: const VisualDensity(vertical: -2), // to compact
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            employee != null
                                ? employee!.job_name.toString()
                                : '',
                            textAlign: TextAlign.left,
                            style: normalLargeGreyText,
                          ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       'Job Grade : ',
                          //       textAlign: TextAlign.left,
                          //       style: normalLargeGreyText,
                          //     ),
                          //     Text(
                          //       employee != null
                          //           ? employee!.job_grade.toString()
                          //           : '',
                          //       textAlign: TextAlign.left,
                          //       style: normalLargeBlueText,
                          //     ),
                          //   ],
                          // ),
                       
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 2,
                    thickness: 1.5,
                  ),
                  ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          MdiIcons.clipboardAccount,
                          color: Color(0xff208d9c),
                        ),
                      ],
                    ),
                    title:
                        Text(context.l10n.registrationNumber, style: normalSmallGreyText),
                    subtitle: Text(
                      employee != null
                          ? employee!.employee_code.toString()
                          : '',
                      style: normalMediumBalckText,
                    ),
                  ),
                  ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(MdiIcons.genderMaleFemale,
                            color: Color(0xff208d9c)),
                      ],
                    ),
                    title: Text(context.l10n.gender, style: normalSmallGreyText),
                    subtitle: Text(
                        employee != null ? employee!.gender.toString() : '',
                        style: normalMediumBalckText),
                  ),
                  ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(MdiIcons.cakeVariant, color: Color(0xff208d9c))
                      ],
                    ),
                    title: Text(context.l10n.birthday, style: normalSmallGreyText),
                    subtitle: Text(
                        employee != null ? employee!.birthday.toString() : '',
                        style: normalMediumBalckText),
                  ),
                  ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(MdiIcons.phone, color: Color(0xff208d9c)),
                      ],
                    ),
                    title: Text(context.l10n.workPhone, style: normalSmallGreyText),
                    subtitle: Text(
                        employee != null ? employee!.work_phone! : '',
                        style: normalMediumBalckText),
                    // trailing: Icon(MdiIcons.messageBulleted,
                    //     color: Color(0xff208d9c)),
                  ),
                  ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(MdiIcons.phone, color: Color(0xff208d9c)),
                      ],
                    ),
                    title: Text(context.l10n.homePhone, style: normalSmallGreyText),
                    subtitle: Text(
                        employee != null ? employee!.mobile_phone! : '',
                        style: normalMediumBalckText),
                  ),
                  ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(MdiIcons.email, color: Color(0xff208d9c)),
                      ],
                    ),
                    title: Text(context.l10n.workEmail, style: normalSmallGreyText),
                    subtitle: Text(
                        employee != null ? employee!.email.toString() : '',
                        style: normalMediumBalckText),
                  ),
                   
                   ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.language, color: Color(0xff208d9c)),
                      ],
                    ),
                    title: Text(context.l10n.language,
                        style: normalSmallGreyText),
                    subtitle: Text(
                        LocaleController.isArabic(context)
                            ? 'العربية'
                            : 'English',
                        style: normalMediumBalckText),
                    trailing: TextButton(
                      onPressed: () => LocaleController.toggle(context),
                      child: Text(LocaleController.isArabic(context)
                          ? 'English'
                          : 'العربية'),
                    ),
                  ),
                   const Divider(
                    height: 2,
                    thickness: 1.5,
                  ),
                   InkWell(
                    onTap: (){
                         Navigator.of(context).pushReplacementNamed('/login');
                      },
                     child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          // Icon(MdiIcons.fileSettings, color: Color(0xff208d9c)),
                        ],
                      ),
                      title: Text('', style: normalSmallGreyText),
                      subtitle: Text(
                         context.l10n.signOut,
                          style: normalLargeBalckText),
                                     ),
                   ),
                   
                  
                ],
              ),
            )
            
            ),
      //  drawer: drawerWidget(context, employee, odoo, createPassword),
      ),
    );
  }
}
