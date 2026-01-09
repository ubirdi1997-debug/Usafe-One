import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// Expandable FAB widget
class ExpandableFAB extends StatefulWidget {
  final List<FABOption> options;
  final VoidCallback? onAuthenticator;
  final VoidCallback? onBackupCodes;
  final VoidCallback? onCalculator;
  final VoidCallback? onBarcodeScanner;
  
  const ExpandableFAB({
    super.key,
    required this.options,
    this.onAuthenticator,
    this.onBackupCodes,
    this.onCalculator,
    this.onBarcodeScanner,
  });
  
  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.fastTransition,
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  void _handleOptionTap(FABOption option) {
    _toggleExpanded();
    Future.delayed(AppConstants.fastTransition, () {
      switch (option.type) {
        case FABOptionType.authenticator:
          widget.onAuthenticator?.call();
          break;
        case FABOptionType.backupCodes:
          widget.onBackupCodes?.call();
          break;
        case FABOptionType.calculator:
          widget.onCalculator?.call();
          break;
        case FABOptionType.barcodeScanner:
          widget.onBarcodeScanner?.call();
          break;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        // Expanded options (reversed order)
        if (_isExpanded)
          ...widget.options.reversed.map((option) {
            final index = widget.options.length - widget.options.indexOf(option) - 1;
            return Positioned(
              bottom: 70 + (index * (AppConstants.expandedFabSize + AppConstants.expandedFabSpacing)),
              right: 0,
              child: _ExpandedFABOption(
                option: option,
                onTap: () => _handleOptionTap(option),
              ),
            );
          }).toList(),
        // Main FAB
        RotationTransition(
          turns: _rotateAnimation,
          child: FloatingActionButton(
            onPressed: _toggleExpanded,
            backgroundColor: _isExpanded
                ? AppTheme.darkSurfaceVariant
                : AppTheme.accentColor,
            foregroundColor: _isExpanded
                ? AppTheme.textPrimary
                : AppTheme.nearBlack,
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}

/// Expanded FAB option widget
class _ExpandedFABOption extends StatelessWidget {
  final FABOption option;
  final VoidCallback onTap;
  
  const _ExpandedFABOption({
    required this.option,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            option.label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: AppTheme.darkSurface,
          foregroundColor: AppTheme.textPrimary,
          mini: true,
          heroTag: option.type.toString(),
          child: Icon(option.icon),
        ),
      ],
    );
  }
}

/// FAB Option model
class FABOption {
  final FABOptionType type;
  final IconData icon;
  final String label;
  
  const FABOption({
    required this.type,
    required this.icon,
    required this.label,
  });
}

/// FAB Option type
enum FABOptionType {
  authenticator,
  backupCodes,
  calculator,
  barcodeScanner,
}

