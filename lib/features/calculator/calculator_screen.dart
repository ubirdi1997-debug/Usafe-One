import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

/// Calculator screen
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _operand;
  String? _operation;
  bool _shouldResetDisplay = false;
  bool _isGstMode = false;
  double _gstRate = 18.0; // Default GST rate
  
  void _onButtonPress(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _operand = null;
        _operation = null;
        _shouldResetDisplay = false;
      } else if (value == '=') {
        if (_isGstMode) {
          // In GST mode, = calculates GST total
          final baseAmount = double.tryParse(_display) ?? 0;
          final total = baseAmount + _calculateGstAmount();
          setState(() {
            if (total == total.truncateToDouble()) {
              _display = total.toInt().toString();
            } else {
              _display = total.toStringAsFixed(2);
            }
          });
        } else if (_operation != null && _operand != null) {
          _calculate();
          _operation = null;
          _operand = null;
          _shouldResetDisplay = true;
        }
      } else if (['+', '-', '×', '÷'].contains(value)) {
        if (_isGstMode) {
          // In GST mode, operations are disabled - just show error
          return;
        }
        final currentValue = double.tryParse(_display) ?? 0;
        
        if (_operation != null && _operand != null) {
          // Chain operations: calculate previous, then set new operation
          _operand = currentValue;
          _calculate();
          _operand = _result;
        } else {
          // First operation
          _operand = currentValue;
        }
        
        _operation = value;
        _expression = _display;
        _shouldResetDisplay = true;
      } else {
        // Number or decimal point
        if (_shouldResetDisplay) {
          _display = value == '.' ? '0.' : value;
          _shouldResetDisplay = false;
          _expression = '';
        } else {
          if (_display == '0' && value != '.') {
            _display = value;
          } else {
            // Prevent double decimal point
            if (value == '.' && _display.contains('.')) {
              return;
            }
            _display += value;
          }
        }
      }
    });
  }
  
  double _result = 0;
  
  void _calculate() {
    if (_operation == null || _operand == null) return;
    
    final currentValue = double.tryParse(_display) ?? 0;
    
    switch (_operation!) {
      case '+':
        _result = _operand! + currentValue;
        break;
      case '-':
        _result = _operand! - currentValue;
        break;
      case '×':
        _result = _operand! * currentValue;
        break;
      case '÷':
        if (currentValue != 0) {
          _result = _operand! / currentValue;
        } else {
          _display = 'Error';
          return;
        }
        break;
    }
    
    // Format result
    if (_result.isInfinite || _result.isNaN) {
      _display = 'Error';
      return;
    }
    
    if (_result == _result.truncateToDouble()) {
      _display = _result.toInt().toString();
    } else {
      // Remove trailing zeros
      String formatted = _result.toStringAsFixed(10);
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      _display = formatted;
    }
    
    if (_display.isEmpty) {
      _display = '0';
    }
  }
  
  /// Calculate GST amount
  double _calculateGstAmount() {
    final baseAmount = double.tryParse(_display) ?? 0;
    return baseAmount * (_gstRate / 100);
  }
  
  /// Calculate GST total (base + GST)
  double _calculateGstTotal() {
    final baseAmount = double.tryParse(_display) ?? 0;
    return baseAmount + _calculateGstAmount();
  }
  
  /// Calculate GST from total amount
  void _calculateGst() {
    final total = double.tryParse(_display) ?? 0;
    if (total > 0 && _gstRate > 0) {
      // Calculate base amount from total
      final baseAmount = total / (1 + (_gstRate / 100));
      setState(() {
        if (baseAmount == baseAmount.truncateToDouble()) {
          _display = baseAmount.toInt().toString();
        } else {
          _display = baseAmount.toStringAsFixed(2);
        }
      });
    }
  }
  
  /// Format number as currency
  String _formatCurrency(double amount) {
    if (amount == amount.truncateToDouble()) {
      return '₹${amount.toInt()}';
    } else {
      return '₹${amount.toStringAsFixed(2)}';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isGstMode = !_isGstMode;
                if (_isGstMode) {
                  _display = '0';
                  _expression = '';
                  _operand = null;
                  _operation = null;
                }
              });
            },
            child: Text(
              _isGstMode ? 'Standard' : 'GST',
              style: TextStyle(
                color: _isGstMode ? AppTheme.accentPrimary : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isGstMode) ...[
                      // GST Rate selector
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'GST Rate: ',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            ...([0.0, 5.0, 12.0, 18.0, 28.0].map((rate) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _gstRate = rate;
                                      _calculateGst();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _gstRate == rate
                                          ? AppTheme.accentPrimary
                                          : AppTheme.backgroundSecondary,
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: Text(
                                      '${rate.toInt()}%',
                                      style: TextStyle(
                                        color: _gstRate == rate
                                            ? AppTheme.backgroundPrimary
                                            : AppTheme.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })),
                          ],
                        ),
                      ),
                      // GST Calculation Display
                      if (_display != '0' && _display != 'Error')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Base: ${_formatCurrency(double.tryParse(_display) ?? 0)}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'GST (${_gstRate.toInt()}%): ${_formatCurrency(_calculateGstAmount())}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total: ${_formatCurrency(_calculateGstTotal())}',
                              style: const TextStyle(
                                color: AppTheme.accentPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                    ],
                    if (_expression.isNotEmpty && !_isGstMode && _operation != null)
                      Text(
                        '$_expression $_operation',
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 20, // --font-size-xl
                        ),
                      ),
                    if (!_isGstMode || _display == '0' || _display == 'Error')
                      const SizedBox(height: 8),
                    Text(
                      _display,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Buttons
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow(['C', '÷', '×', '-']),
                    const SizedBox(height: 12),
                    _buildRow(['7', '8', '9', '+']),
                    const SizedBox(height: 12),
                    _buildRow(['4', '5', '6', '-']),
                    const SizedBox(height: 12),
                    _buildRow(['1', '2', '3', '+']),
                    const SizedBox(height: 12),
                    _buildLastRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLastRow() {
    return Expanded(
      child: Row(
        children: [
          // 0 button (2x width)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _onButtonPress('0');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundSecondary,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Sharp corners
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 48), // --button-height: 48px minimum
                ),
                child: const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 20, // --font-size-xl (Button font: 20px)
                    fontWeight: FontWeight.w500, // --font-weight-medium
                  ),
                ),
              ),
            ),
          ),
          // . button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _onButtonPress('.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundSecondary,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Sharp corners
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 48), // --button-height: 48px minimum
                ),
                child: const Text(
                  '.',
                  style: TextStyle(
                    fontSize: 20, // --font-size-xl (Button font: 20px)
                    fontWeight: FontWeight.w500, // --font-weight-medium
                  ),
                ),
              ),
            ),
          ),
          // = button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _onButtonPress('=');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPrimary,
                  foregroundColor: AppTheme.nearBlack,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Sharp corners
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 48), // --button-height: 48px minimum
                ),
                child: const Text(
                  '=',
                  style: TextStyle(
                    fontSize: 20, // --font-size-xl (Button font: 20px)
                    fontWeight: FontWeight.w500, // --font-weight-medium
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((button) {
          final isOperation = ['+', '-', '×', '÷', '='].contains(button);
          final isClear = button == 'C';
          
          Color backgroundColor;
          Color textColor;
          
          if (isClear) {
            backgroundColor = AppTheme.error;
            textColor = AppTheme.textPrimary;
          } else if (isOperation) {
            backgroundColor = AppTheme.accentColor;
            textColor = AppTheme.nearBlack;
          } else {
            backgroundColor = AppTheme.darkSurface;
            textColor = AppTheme.textPrimary;
          }
          
          final flex = button == '0' ? 2 : 1;
          
          return Expanded(
            flex: flex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _onButtonPress(button);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: textColor,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Sharp corners
                  ),
                  minimumSize: const Size(0, 48), // --button-height: 48px minimum
                  padding: const EdgeInsets.all(20), // Keep padding for visual balance
                ),
                child: Text(
                  button,
                  style: TextStyle(
                    fontSize: 20, // --font-size-xl (Button font: 20px)
                    fontWeight: FontWeight.w500, // --font-weight-medium
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

