import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = "0";
  double? firstOperand;
  String? operation;
  bool clearNext = false;

  @override
  void initState() {
    super.initState();
    _loadLastValue();
  }

  void _loadLastValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      display = prefs.getString('lastValue') ?? "0";
    });
  }

  void _saveLastValue(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastValue', value);
  }

  void _onDigitPress(String digit) {
    setState(() {
      if (clearNext) {
        display = digit;
        clearNext = false;
      } else {
        display = display == "0" ? digit : display + digit;
      }
      if (display.length > 8) {
        display = "OVERFLOW";
        clearNext = true;
      }
    });
  }

  void _onOperatorPress(String op) {
    setState(() {
      firstOperand = double.tryParse(display);
      operation = op;
      clearNext = true;
    });
  }

  void _onEqualsPress() {
    if (firstOperand == null || operation == null) return;
    double? secondOperand = double.tryParse(display);
    if (secondOperand == null) return;
    double result;
    try {
      switch (operation) {
        case '+':
          result = firstOperand! + secondOperand;
          break;
        case '-':
          result = firstOperand! - secondOperand;
          break;
        case '*':
          result = firstOperand! * secondOperand;
          break;
        case '/':
          if (secondOperand == 0) {
            display = "ERROR";
            clearNext = true;
            return;
          }
          result = firstOperand! / secondOperand;
          break;
        default:
          return;
      }
      display = result.toStringAsFixed(8);
      display = display.replaceAll(RegExp(r'\.0+\$'), '');
      _saveLastValue(display);
    } catch (e) {
      display = "ERROR";
    }
    setState(() {
      clearNext = true;
    });
  }

  void _onClearEntryPress() {
    setState(() {
      display = "0";
    });
  }

  void _onClearPress() {
    setState(() {
      display = "0";
      firstOperand = null;
      operation = null;
    });
    _saveLastValue("0");
  }

  Widget _buildButton(String text, Function() onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter Calculator")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Text(display, style: TextStyle(fontSize: 48)),
            ),
          ),
          Column(
            children: [
              Row(children: [
                _buildButton("1", () => _onDigitPress("1")),
                _buildButton("2", () => _onDigitPress("2")),
                _buildButton("3", () => _onDigitPress("3")),
                _buildButton("+", () => _onOperatorPress("+")),
              ]),
              Row(children: [
                _buildButton("4", () => _onDigitPress("4")),
                _buildButton("5", () => _onDigitPress("5")),
                _buildButton("6", () => _onDigitPress("6")),
                _buildButton("-", () => _onOperatorPress("-")),
              ]),
              Row(children: [
                _buildButton("7", () => _onDigitPress("7")),
                _buildButton("8", () => _onDigitPress("8")),
                _buildButton("9", () => _onDigitPress("9")),
                _buildButton("*", () => _onOperatorPress("*")),
              ]),
              Row(children: [
                _buildButton("CE", _onClearEntryPress),
                _buildButton("0", () => _onDigitPress("0")),
                _buildButton("C", _onClearPress),
                _buildButton("/", () => _onOperatorPress("/")),
              ]),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onEqualsPress,
                    child: Text("=", style: TextStyle(fontSize: 24)),
                  ),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
