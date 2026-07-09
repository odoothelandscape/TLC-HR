import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:talent_hr/data/database/dao/attachment_dao.dart';
import 'package:talent_hr/data/database/dao/leave_dao.dart';
import 'package:talent_hr/utility/style/theme.dart' as style;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/api/leave_api.dart';
import '../../../data/database/dao/employee_dao.dart';
import '../../../data/models/employee/employee.dart';
import '../../../data/models/leave/leave.dart';
import '../../../utility/style/theme.dart';
import '../../widgets/custom_event_dialog.dart';
// import '../../widgets/drawer_body.dart';
import '../../widgets/no_data.dart';
import '../dashboard/dashboard_main.dart';
import 'leave_detail_screen.dart';
import 'leave_request_screen.dart';
import 'package:talent_hr/app/locale_controller.dart';

class LeaveHistoryListScreen extends StatefulWidget {
  const LeaveHistoryListScreen({super.key});

  @override
  _LeaveHistoryListScreenState createState() => _LeaveHistoryListScreenState();
}

class _LeaveHistoryListScreenState extends State<LeaveHistoryListScreen> {
  //API
  var leaveApi = LeaveAPI();

//Dao
  var leaveDao = LeaveDao();
  var employeeDao = EmployeeDao();
  var attachmentDao = AttachmentDao();

  Employee? employee;

//Variable
  var pref;
  var userId;
  FToast? toast;
  bool waitingFlag = false;
  String? leaveReasonStr;
  bool noMoreToShow = false;
  bool loading = false;
  List<Leave> leaveList = [];
  final ScrollController _scrollController = ScrollController();
  bool doneRefresh = false;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  initState() {
    super.initState();
    toast = FToast();
    toast!.init(context);
    // for (int i = 0; i < menuActive.length; i++) {
    //   menuActive[i] = false;
    // }
    // menuActive[6] = true;
    _loadData();
  }

  _loadData() async {
    pref = await SharedPreferences.getInstance();
    userId = await pref.getInt('uid');

    employee = await employeeDao.getSingleEmployeeById(userId!);
    loading = true;
    leaveList = [];
    leaveList = await leaveDao.getLeaveList();

    setState(() {});

    await bindData();
  }

  Future bindData() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }
    leaveList = [];
    await leaveApi.getLeaveList();
    leaveList = [];
    leaveList = await leaveDao.getLeaveList();


    if (leaveList.isEmpty) {
      noMoreToShow = true;
      loading = false;
    } else {
      noMoreToShow = false;
      loading = false;
    }

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refreshList() async {
    bool checkInternet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    if (checkInternet == false) {
      showDialog(context: context, builder: (_) => const CustomEventDialog());
      return;
    }
    EasyLoading.show(status: context.l10n.fetchingData);
    doneRefresh = true;
    setState(() {});

    await bindData();
    doneRefresh = false;
    EasyLoading.dismiss();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
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
        appBar: AppBar(
          backgroundColor: style.ColorObj.mainColor,
          title: Text(
            context.l10n.myLeaveHistory,
            style: style.appBarTitleStyle,
          ),
          leading: InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const HomeScreen();
                }));
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.home,
                  size: 25,
                  color: Colors.white,
                ),
              )),
          actions: [
            IgnorePointer(
              ignoring: doneRefresh,
              child: InkWell(
                  onTap: () {
                    setState(() {
                      // leaveList = [];
                      noMoreToShow = false;
                    });
                    refreshList();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  )),
            )
          ],
        ),
        body: leaveList.isNotEmpty
            ? ListView.builder(
                itemCount: leaveList.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (_, index) {
                  Leave leave = leaveList[index];

                  String state = '';
                  String duration =
                      '${leave.number_of_days} days(s) (${leave.date_from} ~ ${leave.date_to})';
                  Color? stateColor;
                  Color? textColor;

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
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LeaveDetailScreen(leave))),
                    child: LeaveRequestCard(
                      date: leave.date_from!,
                      day: leave.date_from!.substring(8, 10),
                      reason: '',
                      leaveType: leave.leave_type!,
                      status: state,
                      statusColor: stateColor!,
                    ),

                  
                  );
                },
              )
            : noMoreToShow
                ? noDataWidget(context)
                : Center(
                    child: Container(
                    child: const CircularProgressIndicator(),
                  )),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          height: 25,
          width: double.infinity,
          child: leaveList.isNotEmpty
              ? Text(
                  '${leaveList.length} records found',
                  style: normalMediumGreyText,
                )
              : Text(
                  context.l10n.noRecordsFound,
                  style: normalMediumGreyText,
                ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
                backgroundColor: ColorObj.mainColor,
                child: const Icon(
                  MdiIcons.calendarAccount,
                  color: Colors.white,
                ),
                label: context.l10n.newLeaveRequest,
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const LeaveRequestScreen()))),

          
          ],
        ),
      ),
    );
  }
}

class LeaveRequestCard extends StatelessWidget {
  final String date;
  final String day;
  final String reason;
  final String leaveType;
  final String status;
  final Color statusColor;

  const LeaveRequestCard({super.key, 
    required this.date,
    required this.day,
    required this.reason,
    required this.leaveType,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    var dateTime1 = DateFormat('yyyy-MM-dd').parse(date);

    final DateFormat format = DateFormat('MMM');

    var month = format.format(dateTime1);
   return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column( // Use Column to stack the month and day containers
              children: [
                Container(
                  width: 60, // Adjust width as needed
                  height: 20, // Adjust height as needed
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 97, 96, 96), // Darker grey for the month
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      month,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white, // Month text in white
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60, // Adjust width as needed
                  height: 30, // Adjust height as needed
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Lighter grey for the day
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        leaveType,
                        style: const TextStyle(fontSize: 14,color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}