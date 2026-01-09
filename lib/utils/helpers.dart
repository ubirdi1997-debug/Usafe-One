import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../core/auth/biometric_auth.dart';

/// Copy to clipboard with biometric authentication and haptic feedback
Future<void> copyToClipboard(
  String text,
  BuildContext context, {
  String? successMessage,
  bool requireBiometric = true,
}) async {
  // Require biometric authentication for sensitive data
  if (requireBiometric) {
    final authenticated = await BiometricAuth.authenticate(
      reason: 'Authenticate to copy sensitive data',
    );
    
    if (!authenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
  }
  
  await Clipboard.setData(ClipboardData(text: text));
  
  // Haptic feedback
  if (await Vibration.hasVibrator() ?? false) {
    await Vibration.vibrate(duration: 50);
  }
  
  // Show snackbar
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage ?? 'Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Format time remaining as MM:SS
String formatTimeRemaining(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

/// Generate unique ID
String generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString() +
      (1000 + (9999 * (0.5 - 0.5))).toInt().toString();
}

