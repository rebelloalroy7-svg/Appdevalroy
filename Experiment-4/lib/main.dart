import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String result = "0";

  void _onPressed(String value) {
    setState(() {
      if (value == "C") {
        input = "";
        result = "0";
      } else if (value == "=") {
        try {
          result = _evaluate(input).toString();
        } catch (e) {
          result = "Error";
        }
      } else {
        input += value;
      }
    });
  }

  double _evaluate(String expression) {
    // Very basic evaluation (only +, -, *, /)
    List<String> tokens = expression.split(RegExp(r'([+\-*/])'));
    double total = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double num = double.parse(tokens[i + 1]);
      if (op == "+") total += num;
      if (op == "-") total -= num;
      if (op == "*") total *= num;
      if (op == "/") total /= num;
    }
    return total;
  }

  Widget buildButton(String text) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(24),
        ),
        onPressed: () => _onPressed(text),
        child: Text(text, style: TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculator")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Text(
                input,
                style: TextStyle(fontSize: 32, color: Colors.black54),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(24),
            child: Text(
              result,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Row(children: [buildButton("7"), buildButton("8"), buildButton("9"), buildButton("/")]),
          Row(children: [buildButton("4"), buildButton("5"), buildButton("6"), buildButton("*")]),
          Row(children: [buildButton("1"), buildButton("2"), buildButton("3"), buildButton("-")]),
          Row(children: [buildButton("C"), buildButton("0"), buildButton("="), buildButton("+")]),
        ],
      ),
    );
  }
}
