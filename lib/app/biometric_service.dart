import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool isSupported = await auth.isDeviceSupported();

      if (!isSupported) {
        return false;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك لتسجيل الحضور أو الانصراف',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}
