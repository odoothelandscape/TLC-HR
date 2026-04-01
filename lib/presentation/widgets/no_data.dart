import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Widget noDataWidget() {
  return Center(
      child: Padding(
    padding: EdgeInsets.all(15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image(
          image: AssetImage('assets/imgs/ic_empty_data.png'),
          width: 250,
          height: 250,
        ),
        Text(
          "No Data",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25,
              color: Colors.red[300],
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "No data found, please try again later.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Refresh the page or check your internet connection.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  ));
}
