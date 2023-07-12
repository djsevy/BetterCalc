// import 'dart:html';

import 'EquationCalc.dart';
import 'HistoryStorage.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'NotesStorage.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
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

  bool firstEquationEntered = false;
  bool scientificNotationMode = false;

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
      } else {
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
      } else if (buttonText == "History") {
      } else if (buttonText == '<') {
        // Move cursor to the left
        if (cursorIndex > 0) cursorIndex--;
      } else if (buttonText == '>') {
        // Move cursor to the right
        if (cursorIndex < _controller.text.length) cursorIndex++;
      } else if (buttonText == '2nd') {
        secondMode = !secondMode;
      } else if (buttonText == 'del') {
        // Delete one character at a time
        if (_controller.text.isNotEmpty && cursorIndex > 0) {
          _controller.text = _controller.text.substring(0, cursorIndex - 1) +
              _controller.text.substring(cursorIndex);
          cursorIndex--;
        }
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
        firstEquationEntered = true;
        return widget.eqcalc.previousAnswer;
      }
      //This is the string of things
    } catch (e) {
      return 'Error';
    }
  }

  Widget _buildEquationButton(String buttonText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(

          padding: const EdgeInsets.only(
              left: 15.0, top: 8.0, bottom: 8.0, right: 15.0),
          
          backgroundColor: Colors.grey),
      onPressed: () => _buttonPressed(buttonText),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 16.0, color: Colors.black),

       
      ),
    );
  }

  Widget _buildAnswerButton(String buttonText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(

          padding: const EdgeInsets.only(
              left: 15.0, top: 8.0, bottom: 8.0, right: 15.0),
        
          backgroundColor: Colors.grey),
      onPressed: () => _buttonPressed(buttonText),
      child: Text(
        _buildAnswerText(buttonText),
        style: const TextStyle(fontSize: 16.0, color: Colors.black),

      ),
    );
  }

  String _buildAnswerText(String buttonText) {
    String converted = "";
    if (scientificNotationMode) {
      try {
        converted = double.parse(buttonText).toStringAsExponential();
      } catch (e) {
        converted = buttonText;
      }
    } else {
      converted = buttonText;
    }
    return converted;
  }

  Widget _buildNormalMode() {
    return Column(
      children: [
        Expanded(
            child: Container(
          child: Column(
            children: [
              Row(children: [

                spacer(),

                _buildButton('History'),
                spacer(),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [


                spacer3(),

                if (firstEquationEntered)
                  _buildEquationButton(widget.eqcalc.previousEquation),
                spacer3(),
              ]),
              if (firstEquationEntered)
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  spacer3(),
                  _buildAnswerButton(widget.eqcalc.previousAnswer),
                  spacer3(),
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
                        fontSize: 17.0, fontWeight: FontWeight.bold),
                    readOnly: true, // To prevent keyboard from popping up
                  ),
                ),
              )),
            ],
          ),
        )),
        // const Divider(),
        if (secondMode) _buildSecondBody() else _buildFirstBody(),
      ],
    );
  }

  Widget spacer() {
    return SizedBox(width: 4.0, height: 2.0);
  }

  Widget spacer2() {
    return SizedBox(width: 2.0, height: 1.0);
  }

  Widget spacer3() {
    return SizedBox(width: 8.0, height: 4.0);
  }

  Widget _buildFirstBody() {
    return Column(
      children: [
        spacer(),
        Row(
          children: [

            spacer(),
            _builClearButton('C'),
            spacer(),
            _buildSecondOperatorButton('del'),
            spacer(),
            _buildSecondOperatorButton('<'),
            spacer(),
            _buildSecondOperatorButton('>'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildFirstSecondButton('2nd'),
            spacer(),
            _buildSpecialButton('sin(', 'sin'),
            spacer(),
            _buildSpecialButton('cos(', 'cos'),
            spacer(),
            _buildSpecialButton('tan(', 'tan'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildSpecialButton('^(', 'xⁿ'),
            spacer(),
            _buildNotSpecialButton('ℼ'),
            spacer(),
            _buildSpecialButton('log(', 'log'),
            spacer(),
            _buildNotSpecialButton('%'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildSpecialButton('^2', 'x²'),
            spacer(),
            _builOperatorButton('('),
            spacer(),
            _builOperatorButton(')'),
            spacer(),
            _builOperatorButton('/'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('7'),
            spacer(),
            _buildNumpadButton('8'),
            spacer(),
            _buildNumpadButton('9'),
            spacer(),
            _builOperatorButton('*'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('4'),
            spacer(),
            _buildNumpadButton('5'),
            spacer(),
            _buildNumpadButton('6'),
            spacer(),
            _builOperatorButton('—'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('1'),
            spacer(),
            _buildNumpadButton('2'),
            spacer(),
            _buildNumpadButton('3'),
            spacer(),
            _builOperatorButton('+'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('0'),
            spacer(),
            _buildNumpadButton('.'),
            spacer(),
            _buildNumpadButton('-'),
            spacer(),
            _builOperatorButton('='),
            spacer(),

          ],
        ),
        spacer2(),
      ],
    );
  }

  Widget _buildSecondBody() {
    return Column(
      children: [
        spacer(),
        Row(
          children: [

            spacer(),
            _builClearButton('C'),
            spacer(),
            _buildSecondOperatorButton('del'),
            spacer(),
            _buildSecondOperatorButton('<'),
            spacer(),
            _buildSecondOperatorButton('>'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildSecondButton('2nd'),
            spacer(),
            _buildSpecialButton('sin^-1(', 'sin⁻¹'),
            spacer(),
            _buildSpecialButton('cos^-1(', 'cos⁻¹'),
            spacer(),
            _buildSpecialButton('tan^-1(', 'tan⁻¹'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildSpecialButton('[]√(', 'ⁿ√‾‾'),
            spacer(),
            _buildSpecialButton('ℯ', '𝘦'),
            spacer(),
            _buildSpecialButton('log[](', 'log₍ ₎'),
            spacer(),
            _buildSpecialButton('ln(', 'ln'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildSpecialButton('√(', '√‾‾'),
            spacer(),
            _builOperatorButton('('),
            spacer(),
            _builOperatorButton(')'),
            spacer(),
            _builOperatorButton('/'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('7'),
            spacer(),
            _buildNumpadButton('8'),
            spacer(),
            _buildNumpadButton('9'),
            spacer(),
            _builOperatorButton('*'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('4'),
            spacer(),
            _buildNumpadButton('5'),
            spacer(),
            _buildNumpadButton('6'),
            spacer(),
            _builOperatorButton('—'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('1'),
            spacer(),
            _buildNumpadButton('2'),
            spacer(),
            _buildNumpadButton('3'),
            spacer(),
            _builOperatorButton('+'),
            spacer(),

          ],
        ),
        spacer2(),
        Row(
          children: [

            spacer(),
            _buildNumpadButton('0'),
            spacer(),
            _buildNumpadButton('.'),
            spacer(),
            _buildNumpadButton('-'),
            spacer(),
            _builOperatorButton('='),
            spacer(),

          ],
        ),
        spacer2(),
      ],
    );
  }


  Widget _buildSpecialButton(String buttonText, String displayText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(

            padding: const EdgeInsets.all(13.0),
            backgroundColor: Colors.indigoAccent),

        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          displayText,
          style: const TextStyle(fontSize: 16.5),
        ),
      ),
    );
  }

  Widget _buildHistoryMode() {
    return Column(
      children: [
        Expanded(
            child: Container(
                child: SingleChildScrollView(
                    child: Column(children: [
          Row(children: [

            spacer(),

            _buildButton('History'), //Have a horizontal bar/break here?
            spacer(),
          ]),
          for (int i = 0; i < this.widget.eqcalc.history.length; i++)
            _buildHistoryItem(i),
        ])))),
      ],
    );
  }

  Widget _buildHistoryItem(int Index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            spacer3(),
            _buildEquationButton(widget.eqcalc.history[Index][0]),
            spacer3(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,

          children: [
            spacer3(),
            _buildAnswerButton(widget.eqcalc.history[Index][1]),
            spacer3(),
          ],

        )
      ],
    );
  }

  Widget _buildButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5),
        ),
      ),
    );
  }

  Widget _buildNumpadButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
          backgroundColor: Color.fromARGB(255, 209, 206, 206),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFirstSecondButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
          backgroundColor: Colors.green,
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSecondButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
          backgroundColor: Color.fromARGB(255, 101, 228, 105),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5, color: Colors.black),
        ),
      ),
    );
  }

  Widget _builOperatorButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
          backgroundColor: Color.fromARGB(255, 156, 154, 154),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5, color: Colors.white),
        ),
      ),
    );
  }

  Widget _builClearButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
          backgroundColor: Colors.red,
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNotSpecialButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
          backgroundColor: Colors.indigoAccent,
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSecondOperatorButton(String buttonText) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(13.0),
          backgroundColor: Colors.indigoAccent,
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16.5, color: Colors.white),
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

  void _updateSettingClearHistory(int count) {
    setState(() {
      widget.historystorage.clearHistory();
      firstEquationEntered = false;
      widget.eqcalc.setHistory("");
      // print("tested");
    });
  }

  void _updateSettingSciNot(bool current) {
    setState(() {
      scientificNotationMode = !scientificNotationMode;
      // print(scientificNotationMode);
      // print("tested2");
    });
  }

  bool _getSciNotMode() {
    return scientificNotationMode;
  }

  @override
  Widget build(BuildContext context) {
    var currentIndex = 0;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
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
        selectedItemColor: const Color.fromARGB(255, 129, 132, 135),
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
              MaterialPageRoute(builder: (context) => NotesPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(
                    scientificNotMode: _getSciNotMode(),
                    clearHistory: _updateSettingClearHistory,
                    sciNotToggle: _updateSettingSciNot),
              ),
            );
          }
        },
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  NotesPage({super.key});

  final NotesStorage notesStorage = NotesStorage();

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // _focusNode = FocusNode();

    _focusNode.requestFocus();
    widget.notesStorage.readNotes().then((value) {
      setState(() {
        _textEditingController.text = value;


        //Can then do a print to see it to check if it's loading properly.
      });
    });
  }

  void _saveNotes() {
    widget.notesStorage.writeToNotes(_textEditingController.text);

    
  }

  Widget spacer() {
    return SizedBox(width: 8.0, height: 4.0);

  }

  Widget _buildSaveButton() {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15.0),
        ),
        onPressed: () => _saveNotes(),
        child: Text(
          'Save',

          style: const TextStyle(fontSize: 17.0),

        ),
      ),
    );
  }

  Widget _buildNotes() {

    return Column(
      children: [
        Expanded(
            child: Container(
          child: Column(

            
            children: [
              // spacer(),
              Row(children: [
                // spacer(),
                _buildSaveButton(),
                // spacer(),
              ]),
              // spacer(),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(14.0),
                alignment: Alignment.bottomLeft,

                child: GestureDetector(
                  child: TextField(
                    autofocus: true,
                    showCursor: true,
                    controller:
                        _textEditingController, // Use TextEditingController
                    decoration: const InputDecoration(
                      hintText: 'Enter your notes...',
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) {
                      setState(() {
                        _textEditingController.text +=
                            '\n'; // Add a new line when the return button is pressed
                      });
                    },
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
            ],
          ),
        )),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
        ),
        body: _buildNotes());
  }
}

class SettingsPage extends StatefulWidget {
  final ValueChanged<int> clearHistory;
  final ValueChanged<bool> sciNotToggle;
  bool scientificNotMode;
  SettingsPage({
    required this.clearHistory,
    required this.sciNotToggle,
    required this.scientificNotMode,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  void _setSciNotToggleState(bool currentState) {
    setState(() {
      widget.sciNotToggle(widget.scientificNotMode);
      widget.scientificNotMode = !widget.scientificNotMode;
    });
  }


  Widget spacer() {
    return SizedBox(width: 8.0, height: 4.0);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(children: [

          spacer(),
          Row(children: [
            spacer(),
            Expanded(
                child: ElevatedButton(
                    onPressed: () => widget.clearHistory(
                        100), // Passing value to the parent widget.
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(13.0),
                    ),
                    child: Text(
                      'Clear History',
                      style: const TextStyle(
                          fontSize:
                              18), //Would set stylings here, including margins? Or is that outside?
                      //Add another row do the 'display in scientific notation' toggle option. Oh, how aboutScienfific notation
                    ))),
            spacer(),
          ]),
          spacer(),
          spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            // spacer(),
            Column(
              children: [
                Text("Display all answers in ",
                  style: const TextStyle(fontSize: 18)),
                Text("scientific notation: ",
                  style: const TextStyle(fontSize: 18)),
              ],
            ),
            

            Switch(
              value: widget.scientificNotMode,
              onChanged: _setSciNotToggleState,
              //     style: StyleElement(
              // padding: const EdgeInsets.only(
              //     left: 15.0, top: 8.0, bottom: 8.0, right: 15.0),
              // alignment: Alignment.bottomLeft),
            ),

          ]),
        ]));
  }
}
