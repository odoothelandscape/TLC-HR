import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:talent_hr/presentation/screens/base.account/welcome_screen.dart';
import 'package:talent_hr/presentation/screens/employee/employee_detail.dart';
import 'package:talent_hr/utility/style/theme.dart' as style;
import '../l10n/gen/app_localizations.dart';
import '../presentation/screens/attendance/attendance_screen.dart';
import '../presentation/screens/base.account/login.dart';
import '../presentation/screens/dashboard/dashboard_main.dart';
import '../presentation/screens/expense/expense_request_history_list_page.dart';
import '../presentation/screens/payslip/pay_slip_list_page.dart';
import 'locale_controller.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: "TLC HR",
          builder: EasyLoading.init(),
          locale: locale,
          supportedLocales: LocaleController.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const HomeScreen(),
            '/employee': (context) => const EmployeeDetailScreen(),
            '/attendance': (context) => const AttendanceScreen(),
            '/payslip': (context) => const PaySlipListScreen(),
            '/expense': (context) => const ExpenseListPage(),
          },
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Regular',
            primaryColor: style.ColorObj.mainColor,
            colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: style.ColorObj.mainColor,
                background: style.ColorObj.mainColor),
          ),
        );
      },
    );
  }
}
