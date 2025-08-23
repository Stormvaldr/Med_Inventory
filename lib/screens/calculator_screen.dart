import 'package:flutter/material.dart';
import 'dart:math';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _previousNumber = '';
  String _operation = '';
  bool _waitingForOperand = false;

  void _inputNumber(String number) {
    setState(() {
      if (_waitingForOperand) {
        _display = number;
        _waitingForOperand = false;
      } else {
        _display = _display == '0' ? number : _display + number;
      }
    });
  }

  void _inputOperation(String nextOperation) {
    setState(() {
      if (_previousNumber.isEmpty) {
        _previousNumber = _display;
      } else if (_operation.isNotEmpty) {
        _calculate();
        _previousNumber = _display;
      }
      
      _waitingForOperand = true;
      _operation = nextOperation;
    });
  }

  void _calculate() {
    double prev = double.tryParse(_previousNumber) ?? 0;
    double current = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operation) {
      case '+':
        result = prev + current;
        break;
      case '-':
        result = prev - current;
        break;
      case '×':
        result = prev * current;
        break;
      case '÷':
        result = current != 0 ? prev / current : 0;
        break;
      case '%':
        result = prev % current;
        break;
      default:
        return;
    }

    setState(() {
      _display = result == result.toInt() ? result.toInt().toString() : result.toStringAsFixed(2);
      _previousNumber = '';
      _operation = '';
      _waitingForOperand = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _previousNumber = '';
      _operation = '';
      _waitingForOperand = false;
    });
  }

  void _clearEntry() {
    setState(() {
      _display = '0';
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_waitingForOperand) {
        _display = '0.';
        _waitingForOperand = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 20,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
                    if (_operation.isNotEmpty && _previousNumber.isNotEmpty)
                      Text(
                        '$_previousNumber $_operation',
                        style: TextStyle(
                          fontSize: 20,
                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onBackground,
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
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Row 1
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            text: 'C',
                            onPressed: _clear,
                            backgroundColor: theme.colorScheme.errorContainer,
                            textColor: theme.colorScheme.onErrorContainer,
                          ),
                          _buildButton(
                            text: 'CE',
                            onPressed: _clearEntry,
                            backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.7),
                            textColor: theme.colorScheme.onErrorContainer,
                          ),
                          _buildButton(
                            text: '⌫',
                            onPressed: _backspace,
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            textColor: theme.colorScheme.onSecondaryContainer,
                          ),
                          _buildButton(
                            text: '÷',
                            onPressed: () => _inputOperation('÷'),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 2
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(text: '7', onPressed: () => _inputNumber('7')),
                          _buildButton(text: '8', onPressed: () => _inputNumber('8')),
                          _buildButton(text: '9', onPressed: () => _inputNumber('9')),
                          _buildButton(
                            text: '×',
                            onPressed: () => _inputOperation('×'),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 3
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(text: '4', onPressed: () => _inputNumber('4')),
                          _buildButton(text: '5', onPressed: () => _inputNumber('5')),
                          _buildButton(text: '6', onPressed: () => _inputNumber('6')),
                          _buildButton(
                            text: '-',
                            onPressed: () => _inputOperation('-'),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 4
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(text: '1', onPressed: () => _inputNumber('1')),
                          _buildButton(text: '2', onPressed: () => _inputNumber('2')),
                          _buildButton(text: '3', onPressed: () => _inputNumber('3')),
                          _buildButton(
                            text: '+',
                            onPressed: () => _inputOperation('+'),
                            backgroundColor: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                    
                    // Row 5
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            text: '%',
                            onPressed: () => _inputOperation('%'),
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            textColor: theme.colorScheme.onSecondaryContainer,
                          ),
                          _buildButton(text: '0', onPressed: () => _inputNumber('0')),
                          _buildButton(text: '.', onPressed: _inputDecimal),
                          _buildButton(
                            text: '=',
                            onPressed: _calculate,
                            backgroundColor: theme.colorScheme.primary,
                            textColor: theme.colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}