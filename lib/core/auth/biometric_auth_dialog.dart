import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'biometric_auth.dart';

/// Biometric authentication dialog with visual feedback
class BiometricAuthDialog extends StatefulWidget {
  final String reason;
  final Function(bool)? onResult;
  
  const BiometricAuthDialog({
    super.key,
    required this.reason,
    this.onResult,
  });
  
  @override
  State<BiometricAuthDialog> createState() => _BiometricAuthDialogState();
}

class _BiometricAuthDialogState extends State<BiometricAuthDialog>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = true;
  bool _isSuccess = false;
  bool _isError = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _authenticate();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _authenticate() async {
    final result = await BiometricAuth.authenticate(reason: widget.reason);
    
    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        if (result) {
          _isSuccess = true;
        } else {
          _isError = true;
        }
      });
      
      if (result) {
        // Show success animation
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          widget.onResult?.call(true);
          Navigator.of(context).pop(true);
        }
      } else {
        // Show error, then close
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          widget.onResult?.call(false);
          Navigator.of(context).pop(false);
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.backgroundSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Biometric icon with animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? AppTheme.success.withOpacity(0.2)
                      : _isError
                          ? AppTheme.error.withOpacity(0.2)
                          : AppTheme.accentSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 40,
                  color: _isSuccess
                      ? AppTheme.success
                      : _isError
                          ? AppTheme.error
                          : AppTheme.accentPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isAuthenticating
                    ? 'Authenticating...'
                    : _isSuccess
                        ? 'Authenticated'
                        : 'Authentication Failed',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.reason,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              if (_isError) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    widget.onResult?.call(false);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

