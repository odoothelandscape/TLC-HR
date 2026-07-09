import 'dart:io';

import 'package:device_info/device_info.dart';

class AppDeviceInfo {
  final String id;
  final String androidId;
  final String device;
  final String model;

  const AppDeviceInfo({
    required this.id,
    required this.androidId,
    required this.device,
    required this.model,
  });
}

class ShareComponentClass {
  Future<AppDeviceInfo> readDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      final identifier =
          '${iosDeviceInfo.identifierForVendor}-${iosDeviceInfo.model}';

      return AppDeviceInfo(
        id: identifier,
        androidId: identifier,
        device: iosDeviceInfo.name,
        model: iosDeviceInfo.model,
      );
    }

    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    return AppDeviceInfo(
      id: androidDeviceInfo.id,
      androidId: androidDeviceInfo.androidId,
      device: androidDeviceInfo.device,
      model: androidDeviceInfo.model,
    );
  }
}
