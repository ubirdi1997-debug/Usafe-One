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
  double _result = 0;
  String _operation = '';
  bool _shouldResetDisplay = false;
  
  void _onButtonPress(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _result = 0;
        _operation = '';
        _shouldResetDisplay = false;
      } else if (value == '=') {
        if (_operation.isNotEmpty) {
          _calculate();
          _operation = '';
          _shouldResetDisplay = true;
        }
      } else if (['+', '-', '×', '÷'].contains(value)) {
        if (_operation.isEmpty) {
          _result = double.tryParse(_display) ?? 0;
          _expression = _display;
        } else {
          _calculate();
        }
        _operation = value;
        _shouldResetDisplay = true;
      } else {
        if (_shouldResetDisplay) {
          _display = value;
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
  
  void _calculate() {
    final currentValue = double.tryParse(_display) ?? 0;
    
    switch (_operation) {
      case '+':
        _result += currentValue;
        break;
      case '-':
        _result -= currentValue;
        break;
      case '×':
        _result *= currentValue;
        break;
      case '÷':
        if (currentValue != 0) {
          _result /= currentValue;
        }
        break;
    }
    
    // Format result
    if (_result == _result.truncateToDouble()) {
      _display = _result.toInt().toString();
    } else {
      _display = _result.toStringAsFixed(10).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    
    if (_display.isEmpty || _display == 'NaN') {
      _display = '0';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nearBlack,
      appBar: AppBar(
        title: const Text('Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
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
                    if (_expression.isNotEmpty)
                      Text(
                        _expression + ' ' + _operation,
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 20,
                        ),
                      ),
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
                  backgroundColor: AppTheme.darkSurface,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
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
                  backgroundColor: AppTheme.darkSurface,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  '.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
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
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.nearBlack,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text(
                  '=',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
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
          final isNumber = RegExp(r'[0-9.]').hasMatch(button);
          final isOperation = ['+', '-', '×', '÷', '='].contains(button);
          final isClear = button == 'C';
          
          Color backgroundColor;
          Color textColor;
          
          if (isClear) {
            backgroundColor = AppTheme.errorColor;
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                child: Text(
                  button,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
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

