import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../crypto/base32_decoder.dart';

/// TOTP generator implementing RFC 6238
class TotpGenerator {
  /// Generate TOTP code
  /// 
  /// [secret] - Base32 encoded secret
  /// [algorithm] - Hashing algorithm (SHA1, SHA256, SHA512)
  /// [digits] - Number of digits (usually 6 or 8)
  /// [period] - Time step in seconds (usually 30)
  /// [time] - Unix timestamp in seconds (UTC). If null, uses current time.
  static String generate({
    required String secret,
    Algorithm algorithm = Algorithm.sha1,
    int digits = 6,
    int period = 30,
    int? time,
  }) {
    final currentTime = time ?? DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final timeStep = currentTime ~/ period;
    
    final secretBytes = Base32Decoder.decode(secret.toUpperCase());
    final timeStepBytes = _intToBytes(timeStep);
    
    final hmac = _createHmac(secretBytes, timeStepBytes, algorithm);
    final code = _dynamicTruncation(hmac, digits);
    
    return code.toString().padLeft(digits, '0');
  }
  
  /// Convert integer to 8-byte big-endian array
  static Uint8List _intToBytes(int value) {
    final bytes = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xff;
      value >>= 8;
    }
    return bytes;
  }
  
  /// Create HMAC using specified algorithm
  static Uint8List _createHmac(
    Uint8List secret,
    Uint8List message,
    Algorithm algorithm,
  ) {
    switch (algorithm) {
      case Algorithm.sha1:
        final hmac = Hmac(sha1, secret);
        return Uint8List.fromList(hmac.convert(message).bytes);
      case Algorithm.sha256:
        final hmac = Hmac(sha256, secret);
        return Uint8List.fromList(hmac.convert(message).bytes);
      case Algorithm.sha512:
        final hmac = Hmac(sha512, secret);
        return Uint8List.fromList(hmac.convert(message).bytes);
    }
  }
  
  /// Dynamic truncation as per RFC 4226
  static int _dynamicTruncation(Uint8List hmac, int digits) {
    final offset = hmac[hmac.length - 1] & 0x0f;
    final binary = ((hmac[offset] & 0x7f) << 24) |
                   ((hmac[offset + 1] & 0xff) << 16) |
                   ((hmac[offset + 2] & 0xff) << 8) |
                   (hmac[offset + 3] & 0xff);
    // Calculate 10^digits correctly
    final divisor = _powerOf10(digits);
    return binary % divisor;
  }
  
  /// Calculate 10^n
  static int _powerOf10(int n) {
    int result = 1;
    for (int i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }
  
  /// Get time remaining until next code refresh
  static int getTimeRemaining({int period = 30, int? time}) {
    final currentTime = time ?? DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return period - (currentTime % period);
  }
  
  /// Get current time step
  static int getTimeStep({int period = 30, int? time}) {
    final currentTime = time ?? DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    return currentTime ~/ period;
  }
}

/// Hashing algorithm enum
enum Algorithm {
  sha1,
  sha256,
  sha512,
}

/// Convert string to Algorithm
Algorithm algorithmFromString(String? str) {
  switch (str?.toLowerCase()) {
    case 'sha256':
      return Algorithm.sha256;
    case 'sha512':
      return Algorithm.sha512;
    case 'sha1':
    default:
      return Algorithm.sha1;
  }
}

