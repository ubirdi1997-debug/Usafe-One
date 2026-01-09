import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'expandable_fab.dart';

/// Draggable expandable FAB widget
class DraggableExpandableFAB extends StatefulWidget {
  final List<FABOption> options;
  final VoidCallback? onAuthenticator;
  final VoidCallback? onBackupCodes;
  final VoidCallback? onSecureNotes;
  final VoidCallback? onCalculator;
  final VoidCallback? onBarcodeScanner;
  
  const DraggableExpandableFAB({
    super.key,
    required this.options,
    this.onAuthenticator,
    this.onBackupCodes,
    this.onSecureNotes,
    this.onCalculator,
    this.onBarcodeScanner,
  });
  
  @override
  State<DraggableExpandableFAB> createState() => _DraggableExpandableFABState();
}

class _DraggableExpandableFABState extends State<DraggableExpandableFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;
  
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
    if (!_isDragging) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }
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
        case FABOptionType.secureNotes:
          widget.onSecureNotes?.call();
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
    final screenSize = MediaQuery.of(context).size;
    final fabSize = 56.0;
    final rightPadding = 20.0;
    final bottomPadding = 20.0;
    
    // Calculate position
    double right = rightPadding + _position.dx;
    double bottom = bottomPadding + _position.dy;
    
    // Clamp to screen bounds
    right = right.clamp(0.0, screenSize.width - fabSize - rightPadding);
    bottom = bottom.clamp(0.0, screenSize.height - fabSize - bottomPadding);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Expanded options
        if (_isExpanded)
          ...widget.options.reversed.map((option) {
            final index = widget.options.length - widget.options.indexOf(option) - 1;
            return Positioned(
              bottom: bottom + fabSize + 12 + (index * (48 + 12)),
              right: right,
              child: _ExpandedFABOption(
                option: option,
                onTap: () => _handleOptionTap(option),
              ),
            );
          }).toList(),
        // Main draggable FAB
        Positioned(
          right: right,
          bottom: bottom,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
                if (_isExpanded) {
                  _toggleExpanded();
                }
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _position += details.delta;
              });
            },
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
              });
            },
            child: RotationTransition(
              turns: _rotateAnimation,
              child: FloatingActionButton(
                onPressed: _toggleExpanded,
                backgroundColor: _isExpanded
                    ? AppTheme.backgroundTertiary
                    : AppTheme.accentPrimary,
                foregroundColor: _isExpanded
                    ? AppTheme.textPrimary
                    : AppTheme.backgroundPrimary,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                  size: AppConstants.fabIconSize,
                ),
              ),
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
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
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.accentSubtle,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              option.icon,
              color: AppTheme.accentPrimary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

