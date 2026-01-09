import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Copy to clipboard with haptic feedback
Future<void> copyToClipboard(
  String text,
  BuildContext context, {
  String? successMessage,
}) async {
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

