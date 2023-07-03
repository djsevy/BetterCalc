import 'EquationCalc.dart';
import 'HistoryStorage.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

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
  final TextEditingController _controller =
      TextEditingController(); // New controller
  int cursorIndex = 0; // Track the cursor index
  bool historyMode = false;
  bool secondMode = false;
  bool firstEquation = false;

  @override
  void initState() {
    super.initState();
    widget.historystorage.readHistory().then((value) {
      setState(() {
        widget.eqcalc.setHistory(
            value); //Can then do a print to see it to check if it's loading properly.
      });
    });
  }

  void _adjustCursor() {
    cursorIndex = _controller.selection.base.offset;
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'History') {
        historyMode = !historyMode;
      }
      else {
        historyMode = false;
      }

      if (buttonText == '=') {
        // Perform calculation
        _calculateResult();
        _controller.text = "";
        cursorIndex = _controller.text.length;
        widget.historystorage.writeToHistory(
            widget.eqcalc.historyString); //This is a big important
      } else if (buttonText == 'C') {
        // Clear the output
        _controller.clear();
        cursorIndex = 0; // Reset cursor index
        widget.historystorage.clearHistory(); //This would also normally force a setHistory to empty on eqCalc.
      } else if (buttonText == "History") {

      }
      else if (buttonText == '<') {
        // Move cursor to the left
        if (cursorIndex > 0) cursorIndex--;
      } else if (buttonText == '>') {
        // Move cursor to the right
        if (cursorIndex < _controller.text.length) cursorIndex++;
      } else if (buttonText == '2nd') {
        secondMode = !secondMode;
      } else {
        // Insert the button text at the cursor index
        _controller.text = _controller.text.substring(0, cursorIndex) +
            buttonText +
            _controller.text.substring(cursorIndex);
        if (cursorIndex < (_controller.text.length - buttonText.length + 1)) {
          cursorIndex += buttonText.length; // Increment cursor index
        }
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
      if (_controller.text == "") {
        return "";
      } else {
        widget.eqcalc.setCurrentEquation(_controller.text);
        widget.eqcalc.solve();
        firstEquation = true;
        return widget.eqcalc.previousAnswer;
      }
      //This is the string of things
    } catch (e) {
      return 'Error';
    }
  }

  Widget _buildToggleButton(String buttonText, bool showButtons) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: showButtons ? Colors.white : null,
          backgroundColor: showButtons ? Colors.blue : null,
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

  Widget _buildEquationButton(String buttonText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(
              left: 15.0, top: 8.0, bottom: 8.0, right: 15.0),
          alignment: Alignment.bottomLeft),
      onPressed: () => _buttonPressed(buttonText),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 15.0),
      ),
    );
  }

  Widget _buildAnswerButton(String buttonText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(
              left: 15.0, top: 8.0, bottom: 8.0, right: 15.0),
          alignment: Alignment.topRight),
      onPressed: () => _buttonPressed(buttonText),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 15.0),
      ),
    );
  }

  Widget _buildNormalMode() {
    return Column(
      children: [
        Expanded(
            child: Container(
          child: Column(
            children: [
              Row(children: [
                _buildButton(''),
              ]),
              Row(children: [
                _buildButton('History'),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                _buildEquationButton(widget.eqcalc.previousEquation),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _buildAnswerButton(widget.eqcalc.previousAnswer),
              ]),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(14.0),
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
              )),
            ],
          ),
        )),
        const Divider(),
        if (secondMode) _buildSecondBody() else _buildFirstBody(),
      ],
    );
  }

  Widget _buildFirstBody() {
    return Column(
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
    );
  }

  Widget _buildSecondBody() {
    return Column(
      children: [
        Row(
          children: [
            _buildButton('C'),
            _buildButton('del'),
            _buildButton('<<'),
            _buildButton('>>'),
          ],
        ),
        Row(
          children: [
            _buildButton('2nd'),
            _buildButton('sin^-1'),
            _buildButton('cos^-1'),
            _buildButton('tan^-1'),
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
    );
  }

  Widget _buildHistoryMode() {
    return Column(
      children: [
        Expanded(
            child: Container(
                child: Column(children: [
          Row(children: [
            _buildButton(''),
          ]),
          Row(children: [
            _buildButton('History'),
          ]),
          for (int i = 0; i < this.widget.eqcalc.history.length; i++)
            _buildHistoryItem(i),
        ]))),
      ],
    );
  }

  Widget _buildHistoryItem(int Index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [_buildEquationButton(widget.eqcalc.history[Index][0])],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildEquationButton(widget.eqcalc.history[Index][1])],
        )
      ],
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

  Widget _buildModeOfCalc() {
    if (historyMode) {
      return _buildHistoryMode();
    } else {
      return _buildNormalMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentIndex = 0;

    return Scaffold(
      body: _buildModeOfCalc(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          if (index == 0) {
            // Handle Home button tap
            // You can customize the behavior here
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }
        },
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: const Center(
        child: Text('Notes Page'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
