import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/backup_codes/backup_code_model.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/storage_keys.dart';

/// Backup codes provider
class BackupCodesNotifier extends StateNotifier<List<BackupCode>> {
  BackupCodesNotifier() : super([]) {
    _loadCodes();
  }
  
  /// Load codes from storage
  Future<void> _loadCodes() async {
    final data = await SecureStorage.load(StorageKeys.backupCodes);
    if (data != null && data['codes'] != null) {
      final codes = (data['codes'] as List)
          .map((json) => BackupCode.fromJson(json as Map<String, dynamic>))
          .toList();
      state = codes;
    }
  }
  
  /// Save codes to storage
  Future<void> _saveCodes() async {
    final codesJson = state.map((code) => code.toJson()).toList();
    await SecureStorage.save(StorageKeys.backupCodes, {'codes': codesJson});
  }
  
  /// Add new backup code
  Future<void> addCode(BackupCode code) async {
    state = [...state, code];
    await _saveCodes();
  }
  
  /// Add multiple backup codes
  Future<void> addCodes(List<BackupCode> codes) async {
    state = [...state, ...codes];
    await _saveCodes();
  }
  
  /// Update backup code
  Future<void> updateCode(BackupCode code) async {
    state = state.map((c) => c.id == code.id ? code : c).toList();
    await _saveCodes();
  }
  
  /// Delete backup code
  Future<void> deleteCode(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _saveCodes();
  }
  
  /// Delete all codes for a service/email
  Future<void> deleteCodesByService(String serviceName, String email) async {
    state = state.where((c) => 
      !(c.serviceName == serviceName && c.email == email)
    ).toList();
    await _saveCodes();
  }
  
  /// Toggle used status
  Future<void> toggleUsed(String id) async {
    state = state.map((c) => 
      c.id == id ? c.copyWith(isUsed: !c.isUsed) : c
    ).toList();
    await _saveCodes();
  }
  
  /// Get codes grouped by service + email
  List<BackupCodeSet> getCodeSets() {
    final Map<String, List<BackupCode>> grouped = {};
    
    for (final code in state) {
      final key = '${code.serviceName}::${code.email}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(code);
    }
    
    return grouped.entries.map((entry) {
      final parts = entry.key.split('::');
      final serviceName = parts[0];
      final email = parts[1];
      final codes = entry.value;
      codes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      return BackupCodeSet(
        id: entry.key,
        serviceName: serviceName,
        email: email,
        codes: codes,
        createdAt: codes.first.createdAt,
      );
    }).toList()
      ..sort((a, b) => a.serviceName.compareTo(b.serviceName));
  }
  
  /// Filter codes by email or service
  List<BackupCode> filterCodes(String query) {
    if (query.isEmpty) return state;
    final lowerQuery = query.toLowerCase();
    return state.where((code) => 
      code.email.toLowerCase().contains(lowerQuery) ||
      code.serviceName.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  /// Get codes by service and email
  List<BackupCode> getCodesByService(String serviceName, String email) {
    return state.where((c) => 
      c.serviceName == serviceName && c.email == email
    ).toList();
  }
}

/// Provider for backup codes
final backupCodesProvider = StateNotifierProvider<BackupCodesNotifier, List<BackupCode>>(
  (ref) => BackupCodesNotifier(),
);

