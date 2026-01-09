import '../otp/totp_generator.dart';

/// Parse otpauth:// URI
class OtpauthParser {
  /// Parse otpauth URI string
  static OtpauthData? parse(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      
      if (uri.scheme != 'otpauth' && uri.scheme != 'otpauth-totp') {
        return null;
      }
      
      final type = uri.host; // 'totp' or 'hotp'
      if (type != 'totp') {
        return null; // Only TOTP supported
      }
      
      final path = uri.path;
      final labelParts = path.split(':');
      final issuer = labelParts.length > 1 ? labelParts[0] : null;
      final accountName = labelParts.length > 1 ? labelParts[1] : labelParts[0];
      
      final secret = uri.queryParameters['secret'];
      if (secret == null || secret.isEmpty) {
        return null;
      }
      
      final algorithm = algorithmFromString(uri.queryParameters['algorithm']);
      final digits = int.tryParse(uri.queryParameters['digits'] ?? '6') ?? 6;
      final period = int.tryParse(uri.queryParameters['period'] ?? '30') ?? 30;
      final issuerFromParam = uri.queryParameters['issuer'];
      
      return OtpauthData(
        secret: secret.toUpperCase(),
        issuer: issuerFromParam ?? issuer ?? '',
        accountName: accountName,
        algorithm: algorithm,
        digits: digits,
        period: period,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Otpauth parsed data
class OtpauthData {
  final String secret;
  final String issuer;
  final String accountName;
  final Algorithm algorithm;
  final int digits;
  final int period;
  
  OtpauthData({
    required this.secret,
    required this.issuer,
    required this.accountName,
    required this.algorithm,
    required this.digits,
    required this.period,
  });
}

