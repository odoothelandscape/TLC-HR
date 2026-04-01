
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'app/root.dart';
import 'utility/utils/share_component.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  sharePref = await SharedPreferences.getInstance();
  deviceIMEI = await PlatformDeviceId.getDeviceId;

  runApp(
    const Root(),
  );
}
 