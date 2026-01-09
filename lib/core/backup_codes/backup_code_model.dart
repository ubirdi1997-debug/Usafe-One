/// Backup code model
class BackupCode {
  final String id;
  final String serviceName;
  final String email;
  final String code;
  final bool isUsed;
  final DateTime createdAt;
  
  BackupCode({
    required this.id,
    required this.serviceName,
    required this.email,
    required this.code,
    required this.isUsed,
    required this.createdAt,
  });
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'email': email,
      'code': code,
      'isUsed': isUsed,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory BackupCode.fromJson(Map<String, dynamic> json) {
    return BackupCode(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      email: json['email'] as String,
      code: json['code'] as String,
      isUsed: json['isUsed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  /// Copy with updated fields
  BackupCode copyWith({
    String? id,
    String? serviceName,
    String? email,
    String? code,
    bool? isUsed,
    DateTime? createdAt,
  }) {
    return BackupCode(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      email: email ?? this.email,
      code: code ?? this.code,
      isUsed: isUsed ?? this.isUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Backup code set model (grouped by service + email)
class BackupCodeSet {
  final String id;
  final String serviceName;
  final String email;
  final List<BackupCode> codes;
  final DateTime createdAt;
  
  BackupCodeSet({
    required this.id,
    required this.serviceName,
    required this.email,
    required this.codes,
    required this.createdAt,
  });
  
  /// Get unused codes count
  int get unusedCount => codes.where((c) => !c.isUsed).length;
  
  /// Get used codes count
  int get usedCount => codes.where((c) => c.isUsed).length;
  
  /// Get display label
  String get label {
    if (serviceName.isNotEmpty) {
      return '$serviceName ($email)';
    }
    return email;
  }
}

