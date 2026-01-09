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
        padding: AppConstants.tilePadding,
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(AppConstants.tileBorderRadius),
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
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatTimeRemaining(timeRemaining),
                  style: TextStyle(
                    color: timeRemaining <= 5 ? AppTheme.errorColor : AppTheme.textSecondary,
                    fontSize: 14,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // OTP Code
            Text(
              code,
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.darkSurfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  timeRemaining <= 5 ? AppTheme.errorColor : AppTheme.accentColor,
                ),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

