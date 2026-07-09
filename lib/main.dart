
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/locale_controller.dart';
import 'app/root.dart';
import 'utility/utils/share_component.dart';




/// Required top-level handler so justification decision pushes
/// (type: attendance_justification) are received while the app is
/// backgrounded/terminated. Display is handled by the OS notification;
/// the requests list refreshes on next open.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  sharePref = await SharedPreferences.getInstance();
  deviceIMEI = await PlatformDeviceId.getDeviceId;
  await LocaleController.load();

  runApp(
    const Root(),
  );
}
 