import 'package:flutter/material.dart';
import 'package:talent_hr/data/api/attendance_api.dart';
import 'package:talent_hr/utility/style/theme.dart';

import '../../widgets/leave_time_picker.dart';
import 'error_dialog.dart';
import 'package:talent_hr/app/locale_controller.dart';

class TimeSelectDialog extends StatefulWidget {
  const TimeSelectDialog({Key? key}) : super(key: key);

  @override
  State<TimeSelectDialog> createState() => _TimeSelectDialogState();
}

class _TimeSelectDialogState extends State<TimeSelectDialog> {
  late final DateTime init;
  late final DateTime lastDate;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int totalDays = 0;
  bool selectTime = false;
  @override
  void initState() {
    super.initState();
    init = DateTime.now();
    lastDate = DateTime(3000);
  }

  int totalDay() => totalDays = endTime.difference(startTime).inDays;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 250,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: ColorObj.mainColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.chooseDate,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimePickerWidget(
                text: context.l10n.startDate,
                timePicker: (t) {
                  setState(() {
                    startTime = t;
                    selectTime = true;
                    totalDays = -1;
                  });
                },
                init: startTime,
              ),
              const SizedBox(
                width: 30,
              ),
              SizedBox(
                  child: Center(
                      child: Text(
                context.l10n.to,
                style: TextStyle(
                    fontSize: 15,
                    color: ColorObj.textColor,
                    fontWeight: FontWeight.bold),
              ))),
              const SizedBox(
                width: 30,
              ),
              selectTime
                  ? TimePickerWidget(
                      text: context.l10n.endDate,
                      timePicker: (t) {
                        setState(() {
                          endTime = t;
                          totalDays = totalDay();
                          if (totalDays < 0) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ErrorDialog(
                                      title: context.l10n.endDateSelectError,
                                      content: Text(
                                        context.l10n.pleaseSelectCorrectEndDate,
                                        style: TextStyle(
                                            color: ColorObj.textColor,
                                            fontSize: 15),
                                      ),
                                      icon: Icons.warning);
                                });
                          }
                        });
                      },
                      init: endTime,
                      totalDays: totalDays,
                    )
                  : InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ErrorDialog(
                                title: context.l10n.dateSelectFailed,
                                content: Text(
                                  context.l10n.pleaseChooseStartDateFirst,
                                  style: TextStyle(
                                      color: ColorObj.textColor, fontSize: 15),
                                ),
                                icon: Icons.warning,
                              );
                            });
                      },
                      child: AbsorbPointer(
                        absorbing: true,
                        child: TimePickerWidget(
                          text: context.l10n.endTime,
                          timePicker: (t) {
                            setState(() {
                              endTime = t;
                            });
                          },
                          init: endTime,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black12)),
                        onPressed: () {
                          Navigator.of(context);
                        },
                        child: Text(context.l10n.cancel))),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black12),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        onPressed: () async {
                          var attendanceApi = AttendanceAPI();
                          await attendanceApi.getAttendanceListByFilter(
                              'custom', startTime.toString().split(' ')[0], endTime.toString().split(' ')[0]);
                        },
                        child: Text(context.l10n.confirm))),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
