import 'dart:async';
import 'dart:io';

import 'EquationCalc.dart';
import 'HistoryStorage.dart';

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
  CalculatorScreen({super.key});

  //Equation class here. final Equation equationcalc;
  //access via widget.equationcalc.property or widget.equationcalc.method() //params as necessary
  final EquationCalc eqcalc = EquationCalc();
  final HistoryStorage historystorage = HistoryStorage();

  //Future<File> for storage here
  //final HistoryStorage storage;
  //access via widget.storage.method

  //Prior to this, create the FutureFiel thing.

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TextEditingController _controller = TextEditingController(); // New controller
  int cursorIndex = 0; // Track the cursor index

  @override
  void initState() {
    super.initState();
    widget.historystorage.readHistory().then((value) {
      setState(() {
        widget.eqcalc.setHistory(value); //Can then do a print to see it to check if it's loading properly.
      });
    });

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
        cursorIndex = _controller.text.length;
        // print(_controller.text);
        // print(widget.eqcalc.history);
        widget.historystorage.writeToHistory(widget.eqcalc.historyString); //This is a big important
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
      } 
      else {
        // Insert the button text at the cursor index
        _controller.text = _controller.text.substring(0, cursorIndex) +
            buttonText +
            _controller.text.substring(cursorIndex);
        if (cursorIndex < (_controller.text.length - buttonText.length + 1))
          cursorIndex += buttonText.length; // Increment cursor index
        if (buttonText == "[]√(") {
          cursorIndex -= 3;
        }
        if (buttonText == "log[](") {
          cursorIndex -= 2;
        }
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
      widget.eqcalc.setCurrentEquation(_controller.text);
      widget.eqcalc.solve();
      return widget.eqcalc.previousAnswer; //This is the string of things
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
                  _buildButton('—'),
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
