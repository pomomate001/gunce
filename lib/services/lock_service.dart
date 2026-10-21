import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// PIN hashing and biometric unlock. The PIN itself is never stored.
abstract final class LockService {
  static String hash(String pin, String salt) => sha256.convert(utf8.encode('gunce:$salt:$pin')).toString();

  static String newSalt() {
    final r = math.Random.secure();
    return base64Url.encode(List.generate(16, (_) => r.nextInt(256)));
  }

  static Future<bool> biometricAvailable() async {
    if (kIsWeb) return false;
    try {
      final auth = LocalAuthentication();
      return await auth.isDeviceSupported() && await auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate(String reason) async {
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('biometric failed: $e');
      return false;
    }
  }
}
