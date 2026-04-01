import 'dart:async';
import 'dart:io';
import 'package:device_info/device_info.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';

class ShareComponentClass {
  InternetConnectionStatus? connection_status;
  late DeviceInfoPlugin deviceInfoPlugin;
  late AndroidDeviceInfo androidDeviceInfo;

  Future<AndroidDeviceInfo> readDeviceId() async {
   
    deviceInfoPlugin = DeviceInfoPlugin();
    var deviceIdentifier;
    androidDeviceInfo = await deviceInfoPlugin.androidInfo;

    deviceIdentifier = androidDeviceInfo;
    return deviceIdentifier;
  }
}
