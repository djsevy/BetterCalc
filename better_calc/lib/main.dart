import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TextEditingController _controller = TextEditingController(); // New controller
  int cursorIndex = 0; // Track the cursor index

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Simulate a tap after the app is opened
    });
  }

  void _adjustCursor() {
    cursorIndex = _controller.selection.base.offset;
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == '=') {
        // Perform calculation
        _controller.text = _calculateResult();
      } else if (buttonText == 'C') {
        // Clear the output
        _controller.clear();
        cursorIndex = 0; // Reset cursor index
      } else if (buttonText == '<') {
        // Move cursor to the left
        if (cursorIndex > 0) cursorIndex--;
      } else if (buttonText == '>') {
        // Move cursor to the right
        if (cursorIndex < _controller.text.length) cursorIndex++;
      } else {
        // Insert the button text at the cursor index
        _controller.text = _controller.text.substring(0, cursorIndex) +
            buttonText +
            _controller.text.substring(cursorIndex);
        if (cursorIndex < _controller.text.length)
          cursorIndex++; // Increment cursor index
      }
      // Update cursor position
      _controller.selection = TextSelection.collapsed(offset: cursorIndex);
    });
  }

  String _calculateResult() {
    try {
      // Evaluate the mathematical expression
      // You can use a library like math_expressions for this
      // Here, we'll just return the same text as an example
      return _controller.text;
    } catch (e) {
      return 'Error';
    }
  }

  Widget _buildToggleButton(String buttonText, bool showButtons) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15.0),
          primary: showButtons ? Colors.blue : null,
          onPrimary: showButtons ? Colors.white : null,
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 15.0),
        ),
      ),
    );
  }

  Widget _buildToggledButtonsRow(List<String> buttons) {
    return Row(
      children:
          buttons.map((buttonText) => _buildToggledButton(buttonText)).toList(),
    );
  }

  Widget _buildToggledButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15.0),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 15.0),
        ),
      ),
    );
  }

  Widget _buildButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15.0),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 15.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(14.0),
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                child: TextField(
                  onTap: _adjustCursor,
                  autofocus: true,
                  showCursor: true,
                  controller: _controller, // Use TextEditingController
                  style: const TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.bold),
                  readOnly: true, // To prevent keyboard from popping up
                ),
              ),
            ),
          ),
          const Divider(),
          Column(
            children: [
              Row(
                children: [
                  _buildButton('C'),
                  _buildButton('del'),
                  _buildButton('<'),
                  _buildButton('>'),
                ],
              ),
              Row(
                children: [
                  _buildButton('2nd'),
                  _buildButton('sin'),
                  _buildButton('cos'),
                  _buildButton('tan'),
                ],
              ),
              Row(
                children: [
                  _buildButton('x^y'),
                  _buildButton('log'),
                  _buildButton('pi'),
                  _buildButton('%'),
                ],
              ),
              Row(
                children: [
                  _buildButton('x^2'),
                  _buildButton('('),
                  _buildButton(')'),
                  _buildButton('/')
                ],
              ),
              Row(
                children: [
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('*'),
                ],
              ),
              Row(
                children: [
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('-'),
                ],
              ),
              Row(
                children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('+'),
                ],
              ),
              Row(
                children: [
                  _buildButton('0'),
                  _buildButton('.'),
                  _buildButton('-'),
                  _buildButton('='),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
