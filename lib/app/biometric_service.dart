import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;

      bool isSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isSupported) {
        return false;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to check in/out',
        options: const AuthenticationOptions(
          biometricOnly: true,
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
