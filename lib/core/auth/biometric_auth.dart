import 'package:local_auth/local_auth.dart';

/// Biometric authentication service
class BiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();
  
  /// Check if biometric authentication is available
  static Future<bool> isAvailable() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return isAvailable || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  /// Authenticate with biometrics
  /// Returns true if authentication succeeds, false otherwise
  static Future<bool> authenticate({
    String reason = 'Authenticate to access sensitive data',
  }) async {
    try {
      final isAvailable = await isAvailable();
      if (!isAvailable) {
        return false;
      }
      
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
  
  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}

