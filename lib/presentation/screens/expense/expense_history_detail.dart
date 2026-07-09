import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent_hr/data/database/dao/employee_dao.dart';
import 'package:talent_hr/data/models/expense/expense/expense.dart';
import 'package:talent_hr/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/employee/employee.dart';
import '../../../utility/style/theme.dart';
import 'package:talent_hr/app/locale_controller.dart';

class ExpenseHistoryDetailScreen extends StatefulWidget {
  final Expense expense;
  const ExpenseHistoryDetailScreen(this.expense, {super.key});
  @override
  _ExpenseHistoryDetailScreenState createState() =>
      _ExpenseHistoryDetailScreenState(expense);
}

class _ExpenseHistoryDetailScreenState
    extends State<ExpenseHistoryDetailScreen> {
  Expense expense;

  _ExpenseHistoryDetailScreenState(this.expense);

  FToast? toast;
  Employee? employee;

  var employeeDao = EmployeeDao();

  var uid;
  var pref;

  var stateColor;
  var state = '';
  NumberFormat numberFormat = NumberFormat("#,###", "en_US");
  var amount = '';

  Color? textColor;

  @override
  initState() {
    toast = FToast();
    toast!.init(context);
    super.initState();
    
  }

  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      _loadData();
    }
  }

  @override
  void dispose() {
   
    super.dispose();
  }

  _loadData() async {

    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(uid);

    if (expense.total != null) {
      amount = numberFormat.format(expense.total);
    }

    if (expense.state == 'draft') {
      state = context.l10n.toReport;
      stateColor = Colors.grey[300];
      textColor = Colors.grey[800];
    }
    if (expense.state == 'submitted') {
      state = context.l10n.submitted;
      stateColor = Colors.orange;
      textColor = Colors.white;
    }
     if (expense.state == 'reported') {
      state = context.l10n.toSubmit;
      stateColor = const Color.fromARGB(255, 107, 103, 59);
      textColor = Colors.white;
    }
    if (expense.state == 'approved') {
      state = context.l10n.approved;
      stateColor = Colors.cyan;
      textColor = Colors.white;
    }
    if (expense.state == 'done') {
      state = context.l10n.paid;
      stateColor = Colors.green;
      textColor = Colors.white;
    }
    if (expense.state == 'refused') {
      state = context.l10n.refused;
      stateColor = Colors.red;
      textColor = Colors.white;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        await Navigator.pushReplacementNamed(context, '/expense');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: style.ColorObj.mainColor,
          title: Text(
            context.l10n.paymentRequestDetail,
            style: appBarTitleStyle,
          ),
          leading: InkWell(
              onTap: () async {
                await Navigator.pushReplacementNamed(context, '/expense');
              },
              child: Container(
                  child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ))),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height - 80,
                padding: const EdgeInsets.all(10),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  context.l10n.paymentItem,
                                  style: normalMediumGreyText,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  expense.expenseProductName!,
                                  style: normalDoubleXLBalckText,
                                  overflow: TextOverflow.visible,
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 1),
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: stateColor,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Text(
                                      state.toString(),
                                      style: TextStyle(
                                          fontFamily: 'Regular',
                                          fontSize: 13,
                                          color: textColor),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(
                              MdiIcons.alarm,
                              size: 65,
                              color: style.ColorObj.mainColor,
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              expense.date!,
                              style: style.boldXXLBlueText,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                context.l10n.description,
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                expense.description!,
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                context.l10n.amount,
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                amount != '' ? '$amount  ' : '',
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                context.l10n.note,
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                expense.note!,
                                style: normalLargeBalckText,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
