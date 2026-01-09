import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for encrypted local storage
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  /// Save JSON data
  static Future<void> save(String key, Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    await _storage.write(key: key, value: jsonString);
  }
  
  /// Load JSON data
  static Future<Map<String, dynamic>?> load(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// Delete data
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
  
  /// Check if key exists
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
  
  /// Get all keys
  static Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
  
  /// Delete all data
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

