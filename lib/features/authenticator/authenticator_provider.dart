import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/otp/authenticator_model.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/storage_keys.dart';

/// Authenticator tokens provider
class AuthenticatorNotifier extends StateNotifier<List<AuthenticatorToken>> {
  AuthenticatorNotifier() : super([]) {
    _loadTokens();
  }
  
  /// Load tokens from storage
  Future<void> _loadTokens() async {
    final data = await SecureStorage.load(StorageKeys.authenticators);
    if (data != null && data['tokens'] != null) {
      final tokens = (data['tokens'] as List)
          .map((json) => AuthenticatorToken.fromJson(json as Map<String, dynamic>))
          .toList();
      state = tokens;
    }
  }
  
  /// Save tokens to storage
  Future<void> _saveTokens() async {
    final tokensJson = state.map((token) => token.toJson()).toList();
    await SecureStorage.save(StorageKeys.authenticators, {'tokens': tokensJson});
  }
  
  /// Add new token
  Future<void> addToken(AuthenticatorToken token) async {
    state = [...state, token];
    await _saveTokens();
  }
  
  /// Update token
  Future<void> updateToken(AuthenticatorToken token) async {
    state = state.map((t) => t.id == token.id ? token : t).toList();
    await _saveTokens();
  }
  
  /// Delete token
  Future<void> deleteToken(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _saveTokens();
  }
  
  /// Get token by ID
  AuthenticatorToken? getToken(String id) {
    try {
      return state.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Provider for authenticator tokens
final authenticatorProvider = StateNotifierProvider<AuthenticatorNotifier, List<AuthenticatorToken>>(
  (ref) => AuthenticatorNotifier(),
);

