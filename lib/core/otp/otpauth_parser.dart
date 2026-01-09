import '../otp/totp_generator.dart';

/// Parse otpauth:// URI
class OtpauthParser {
  /// Parse otpauth URI string
  static OtpauthData? parse(String uriString) {
    try {
      final uri = Uri.parse(uriString.trim());
      
      // Check scheme
      if (uri.scheme != 'otpauth') {
        return null;
      }
      
      // Check type (totp or hotp) - it's in the host part
      final type = uri.host.toLowerCase();
      if (type != 'totp') {
        return null; // Only TOTP supported
      }
      
      // Parse label (issuer:account or just account)
      // Path format: /issuer:account or /account
      String path = uri.path;
      if (path.startsWith('/')) {
        path = path.substring(1);
      }
      
      String issuer = '';
      String accountName = '';
      
      if (path.contains(':')) {
        final parts = path.split(':');
        issuer = Uri.decodeComponent(parts[0]);
        accountName = Uri.decodeComponent(parts.sublist(1).join(':'));
      } else {
        accountName = Uri.decodeComponent(path);
      }
      
      // Get secret from query parameters
      final secret = uri.queryParameters['secret'];
      if (secret == null || secret.isEmpty) {
        return null;
      }
      
      // Get optional parameters
      final algorithm = algorithmFromString(uri.queryParameters['algorithm']);
      final digits = int.tryParse(uri.queryParameters['digits'] ?? '6') ?? 6;
      final period = int.tryParse(uri.queryParameters['period'] ?? '30') ?? 30;
      
      // Issuer can be in query parameter (takes precedence) or in label
      final issuerFromParam = uri.queryParameters['issuer'];
      if (issuerFromParam != null && issuerFromParam.isNotEmpty) {
        issuer = Uri.decodeComponent(issuerFromParam);
      }
      
      if (accountName.isEmpty) {
        return null;
      }
      
      return OtpauthData(
        secret: secret.toUpperCase().replaceAll(' ', ''),
        issuer: issuer,
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

