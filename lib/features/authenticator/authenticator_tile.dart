import 'package:flutter/material.dart';
import '../../core/otp/authenticator_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Authenticator token tile widget
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
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: AppConstants.tilePaddingInsets, // --tile-padding: 16px
        decoration: const BoxDecoration(
          color: AppTheme.backgroundSecondary, // --tile-background: #1a1a1a
          borderRadius: BorderRadius.zero, // --tile-border-radius: 0px
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service name and countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    token.label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary, // White
                      fontSize: 15, // --font-size-md (Service name: 15px)
                      fontWeight: FontWeight.w500, // --font-weight-medium
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatTimeRemaining(timeRemaining),
                  style: TextStyle(
                    color: timeRemaining <= 5 ? AppTheme.error : AppTheme.textSecondary,
                    fontSize: 13, // --font-size-sm
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.tileGap), // --tile-gap: 12px
            // OTP Code
            Text(
              code,
              style: const TextStyle(
                color: AppTheme.textPrimary, // White (OTP code: 32px white)
                fontSize: 32, // --tile-code-size: 32px
                fontWeight: FontWeight.w600, // --font-weight-semibold
                letterSpacing: 4,
                fontFeatures: [FontFeature.tabularFigures()], // tabular-nums
              ),
            ),
            SizedBox(height: AppConstants.tileGap), // --tile-gap: 12px
            // Progress indicator (Countdown bar)
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.accentSubtle, // --countdown-background: rgba(5, 150, 105, 0.2)
                valueColor: AlwaysStoppedAnimation<Color>(
                  timeRemaining <= 5 ? AppTheme.error : AppTheme.accentPrimary, // --countdown-fill: #059669
                ),
                minHeight: AppConstants.tileCountdownHeight, // --countdown-height: 2px
              ),
            ),
          ],
        ),
      ),
    );
  }
}

