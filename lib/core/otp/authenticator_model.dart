import '../otp/totp_generator.dart';

/// Authenticator token model
class AuthenticatorToken {
  final String id;
  final String secret;
  final String issuer;
  final String accountName;
  final Algorithm algorithm;
  final int digits;
  final int period;
  final DateTime createdAt;
  
  AuthenticatorToken({
    required this.id,
    required this.secret,
    required this.issuer,
    required this.accountName,
    required this.algorithm,
    required this.digits,
    required this.period,
    required this.createdAt,
  });
  
  /// Generate current TOTP code
  String generateCode() {
    return TotpGenerator.generate(
      secret: secret,
      algorithm: algorithm,
      digits: digits,
      period: period,
    );
  }
  
  /// Get time remaining until next refresh
  int getTimeRemaining() {
    return TotpGenerator.getTimeRemaining(period: period);
  }
  
  /// Get display label (issuer: accountName or accountName)
  String get label {
    if (issuer.isNotEmpty) {
      return '$issuer: $accountName';
    }
    return accountName;
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'secret': secret,
      'issuer': issuer,
      'accountName': accountName,
      'algorithm': algorithm.name,
      'digits': digits,
      'period': period,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory AuthenticatorToken.fromJson(Map<String, dynamic> json) {
    return AuthenticatorToken(
      id: json['id'] as String,
      secret: json['secret'] as String,
      issuer: json['issuer'] as String,
      accountName: json['accountName'] as String,
      algorithm: algorithmFromString(json['algorithm'] as String?),
      digits: json['digits'] as int,
      period: json['period'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  /// Copy with updated fields
  AuthenticatorToken copyWith({
    String? id,
    String? secret,
    String? issuer,
    String? accountName,
    Algorithm? algorithm,
    int? digits,
    int? period,
    DateTime? createdAt,
  }) {
    return AuthenticatorToken(
      id: id ?? this.id,
      secret: secret ?? this.secret,
      issuer: issuer ?? this.issuer,
      accountName: accountName ?? this.accountName,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

