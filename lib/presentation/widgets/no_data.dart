import 'package:flutter/material.dart';
import 'package:talent_hr/app/locale_controller.dart';

Widget noDataWidget(BuildContext context) {
  return Center(
      child: Padding(
    padding: const EdgeInsets.all(15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Image(
          image: AssetImage('assets/imgs/ic_empty_data.png'),
          width: 250,
          height: 250,
        ),
        Text(
          context.l10n.noData,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25,
              color: Colors.red[300],
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          context.l10n.noDataFound,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          context.l10n.refreshOrCheckInternet,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  ));
}
