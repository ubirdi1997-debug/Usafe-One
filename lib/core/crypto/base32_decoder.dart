import 'dart:typed_data';

/// Base32 decoder for TOTP secrets
class Base32Decoder {
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  
  /// Decode Base32 string to bytes
  static Uint8List decode(String input) {
    // Remove whitespace and padding
    final cleaned = input.toUpperCase().replaceAll(RegExp(r'[\s=]'), '');
    
    if (cleaned.isEmpty) {
      return Uint8List(0);
    }
    
    final output = <int>[];
    int buffer = 0;
    int bitsCollected = 0;
    
    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      final charValue = _base32Chars.indexOf(char);
      
      if (charValue < 0) {
        throw FormatException('Invalid Base32 character: $char');
      }
      
      buffer = (buffer << 5) | charValue;
      bitsCollected += 5;
      
      if (bitsCollected >= 8) {
        output.add((buffer >> (bitsCollected - 8)) & 0xFF);
        bitsCollected -= 8;
      }
    }
    
    return Uint8List.fromList(output);
  }
  
  /// Check if string is valid Base32
  static bool isValid(String input) {
    try {
      final cleaned = input.toUpperCase().replaceAll(RegExp(r'[\s=]'), '');
      for (int i = 0; i < cleaned.length; i++) {
        if (!_base32Chars.contains(cleaned[i])) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

