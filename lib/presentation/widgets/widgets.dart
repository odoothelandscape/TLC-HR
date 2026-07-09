import 'package:flutter/material.dart';
import 'package:talent_hr/utility/style/theme.dart' as style;

import '../../utility/style/theme.dart';

class Widgets {
  Widget getSuccessToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green[500],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }


 Widget getDownloadToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: ColorObj.mainColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }




  Widget getErrorToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.clear,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget getWarningToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.yellow[900],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget getInfoToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: ColorObj.mainColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget getInfoBlueToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.blue[800],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info,
            color: style.ColorObj.mainColor,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget onlineToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green[500],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget noInternetToast(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4.0,
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
