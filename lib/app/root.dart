import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:talent_hr/presentation/screens/base.account/welcome_screen.dart';
import 'package:talent_hr/presentation/screens/employee/employee_detail.dart';
import 'package:talent_hr/utility/style/theme.dart' as Style;
import '../presentation/screens/attendance/attendance_screen.dart';
import '../presentation/screens/base.account/login.dart';
import '../presentation/screens/dashboard/dashboard_main.dart';
import '../presentation/screens/expense/expense_request_history_list_page.dart';
import '../presentation/screens/leave/leave_dashboard.dart';
import '../presentation/screens/payslip/pay_slip.dart';
import '../presentation/screens/payslip/pay_slip_list_page.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TLC HR",
      builder: EasyLoading.init(),
      //supportedLocales: context.supportedLocales,
      // localizationsDelegates: context.localizationDelegates,
      // locale: context.locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) =>  LoginScreen(),
        '/dashboard': (context) =>  HomeScreen(),
        '/employee': (context) =>  EmployeeDetailScreen(),
        '/attendance': (context) =>  AttendanceScreen(),
        '/leave': (context) =>  LeaveDashBoardScreen(),
        '/payslip': (context) => const PaySlipListScreen(),
        '/expense': (context) => const ExpenseListPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Regular',
        primaryColor: Style.ColorObj.mainColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Style.ColorObj.mainColor, background: Style.ColorObj.mainColor),
      ),
    );
  }
}
