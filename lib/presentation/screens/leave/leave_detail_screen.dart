import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent_hr/data/api/leave_api.dart';
import 'package:talent_hr/data/database/dao/attachment_dao.dart';
import 'package:talent_hr/data/database/dao/employee_dao.dart';
import 'package:talent_hr/data/database/dao/leave_dao.dart';
import 'package:talent_hr/data/database/dao/leave_reason_dao.dart';
import 'package:talent_hr/presentation/screens/leave/leave_history_list_screen.dart';
import 'package:talent_hr/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/attachment/attachment.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/leave/leave.dart';
import '../../../data/models/leave_reason/leave_reason.dart';
import '../../../utility/style/theme.dart';
import 'package:talent_hr/app/locale_controller.dart';

class LeaveDetailScreen extends StatefulWidget {
  final Leave leave;
  const LeaveDetailScreen(this.leave, {super.key});
  @override
  _LeaveDetailScreenState createState() => _LeaveDetailScreenState(leave);
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  //API
  var leaveApi = LeaveAPI();

  //Dao
  var leaveDao = LeaveDao();
  var employeeDao = EmployeeDao();
  var attachmentDao = AttachmentDao();
  var leaveReasonDao = LeaveReasonDao();

  Leave leave;
  Employee? employee;

  //Variable
  var approvalState;
  var pref;
  var uid;
  var state = '';
  var userLevel;
  String? hourFrom, hourTo;

  FToast? toast;
  String? buttonText = 'Confirm';
  bool buttonFlag = false;
  String? duration;
  List<LeaveReason> leaveReason = [];
  List<Attachment>? attachments;
  Color? stateColor;
  Color? textColor;

  _LeaveDetailScreenState(this.leave);

  @override
  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
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
    if (leave.state == "draft") {
      state = context.l10n.toConfirm;

      stateColor = Colors.grey[300];
      textColor = Colors.grey[800];
    } else if (leave.state == "confirm") {
      state = context.l10n.toApprove;

      stateColor = Colors.orange;
      textColor = Colors.white;
    } else if (leave.state == "validate1") {
      state = context.l10n.secondApproval;

      stateColor = Colors.cyan;
      textColor = Colors.white;
    } else if (leave.state == "validate") {
      state = context.l10n.approved;

      stateColor = Colors.green;
      textColor = Colors.white;
    } else if (leave.state == "cancel") {
      state = context.l10n.cancelled;
      stateColor = Colors.red;
      textColor = Colors.white;
    } else if (leave.state == "refuse") {
      state = context.l10n.refused;
      stateColor = Colors.red;
      textColor = Colors.white;
    }
    duration =
        '${leave.number_of_days} days(s) (${leave.date_from} ~ ${leave.date_to})';
    pref = await SharedPreferences.getInstance();
    uid = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(uid);
  }

  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);

    return WillPopScope(
      onWillPop: () async {
        await Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return const LeaveHistoryListScreen();
        }));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: style.ColorObj.mainColor,
            title: Text(context.l10n.leaveHistoryDetail),
            leading: InkWell(
                onTap: () async {
                  await Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return const LeaveHistoryListScreen();
                  }));
                },
                child: Container(
                    child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                )))),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  context.l10n.type,
                                  style: normalMediumGreyText,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  leave != null ? leave.leave_type! : '',
                                  style: normalDoubleXLBalckText,
                                )
                              ],
                            ),
                            Column(
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
                            Expanded(
                              child: Text(
                                leave.write_date!.substring(0, 10),
                                style: style.boldXXLBlueText,
                              ),
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
                                context.l10n.leaveReason,
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Flexible(
                                child: Text(
                                  leave != null ? leave.name! : '',
                                  style: normalLargeBalckText,
                                ),
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
                                context.l10n.duration,
                                style: normalLargeGreyText,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                duration.toString(),
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
