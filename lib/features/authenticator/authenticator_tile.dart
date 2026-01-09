import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/otp/authenticator_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Authenticator token tile widget - Matching Figma design
class AuthenticatorTile extends StatelessWidget {
  final AuthenticatorToken token;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  
  const AuthenticatorTile({
    super.key,
    required this.token,
    required this.onTap,
    this.onLongPress,
  });
  
  @override
  Widget build(BuildContext context) {
    final code = token.generateCode();
    final timeRemaining = token.getTimeRemaining();
    final progress = timeRemaining / token.period;
    
    // Get service initial for icon
    final serviceInitial = token.issuer.isNotEmpty 
        ? token.issuer[0].toUpperCase()
        : token.accountName.isNotEmpty 
            ? token.accountName[0].toUpperCase()
            : '?';
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16), // p-4
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary, // bg-card
          borderRadius: BorderRadius.circular(12), // rounded-xl
          border: Border.all(
            color: AppTheme.borderColor, // border-border
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service header with icon and more button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Service icon with initial
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accentSubtle, // bg-primary/10
                        borderRadius: BorderRadius.circular(8), // rounded-lg
                      ),
                      child: Center(
                        child: Text(
                          serviceInitial,
                          style: const TextStyle(
                            color: AppTheme.accentPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Service name and account
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          token.issuer.isNotEmpty ? token.issuer : 'Account',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          token.accountName,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // More button
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: onLongPress,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            // Email
            if (token.accountName.contains('@'))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  token.accountName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            // Divider
            const Divider(
              color: AppTheme.borderColor,
              thickness: 1,
              height: 16,
            ),
            // OTP Code and Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // OTP Code
                Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    child: Row(
                      children: [
                        // OTP digits
                        Row(
                          children: code.split('').map((digit) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Text(
                                digit,
                                style: const TextStyle(
                                  color: AppTheme.accentPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  letterSpacing: 2,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 8),
                        // Copy icon
                        Icon(
                          Icons.copy,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                // Circular timer
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      // Background circle
                      CustomPaint(
                        size: const Size(40, 40),
                        painter: _CircularTimerPainter(
                          progress: 1.0,
                          color: AppTheme.backgroundTertiary,
                        ),
                      ),
                      // Progress circle
                      CustomPaint(
                        size: const Size(40, 40),
                        painter: _CircularTimerPainter(
                          progress: progress,
                          color: timeRemaining < 10 
                              ? AppTheme.error 
                              : AppTheme.accentPrimary,
                        ),
                      ),
                      // Time remaining text
                      Center(
                        child: Text(
                          timeRemaining.toString(),
                          style: TextStyle(
                            color: timeRemaining < 10 
                                ? AppTheme.error 
                                : AppTheme.accentPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for circular timer
class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  _CircularTimerPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - paint.strokeWidth) / 2;
    
    // Draw arc
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
