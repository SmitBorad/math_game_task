import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_task/app_utills/app_list.dart';
import 'package:flutter_task/app_utills/common_function.dart';
import 'package:flutter_task/app_utills/common_snackbar.dart';

class GameView extends StatefulWidget {
  GameView({Key? key}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  String question = "";
  String answer = "";
  int userPoint = 0;
  int life = 3;
  int secondsRemaining = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    resetTimer();
    question = generateMathQuestion(AppList.operation);
    print("Math Question: $question");
  }

  void resetTimer() {
    secondsRemaining = 10;
    _timer.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timer.cancel();
          life--;
          if (life > 0) {
            startGame();
          } else {
            // Game Over
            answer = "";
            showGameOverDialog();
          }
        }
      });
    });
  }

  void checkAnswer(String answer) {
    if (answer == calculateAnswer(question).toString()) {
      userPoint++;
    } else {
      life--;
      if (life > 0) {
        startGame();
      } else {
        // Game Over
        showGameOverDialog();
      }
    }
    startGame();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your Score: $userPoint'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    userPoint = 0;
    life = 3;
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(life < 0 ? 0 : life, (index) => const Icon(Icons.favorite)),
        ),
        actions: [
          Center(child: Text("Points: $userPoint")),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.maxFinite,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(
                        height: 200 * ((secondsRemaining / 10)),
                      )
                    ],
                  ),
                ),
                Text(
                  question,
                  style: textTheme.headline6,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            answer.isEmpty ? "Enter Your Answer" : answer,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: NumberKeyboardGrid(
              onKeyPress: (val) {
                if (val == 'send') {
                  if (answer.isEmpty) {
                    showCustomSnackBar(context, "Please Enter Answer");
                  } else {
                    checkAnswer(answer);
                    answer = "";
                  }
                } else if (val == 'backspace') {
                  if (answer.isNotEmpty) {
                    setState(() {
                      answer = answer.substring(0, answer.length - 1);
                    });
                  }
                } else {
                  setState(() {
                    answer += val;
                  });
                  log(answer, name: "KeyInput");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NumberKeyboardGrid extends StatelessWidget {
  final List<String> numberKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

  final Function(String) onKeyPress;

  NumberKeyboardGrid({required this.onKeyPress});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 10.0,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 10.0,
      children: numberKeys.map((String key) {
        return NumberKeyButton(
          number: key,
          onPressed: () => onKeyPress(key),
        );
      }).toList()
        ..add(
          NumberKeyButton(
            number: '⌫',
            onPressed: () => onKeyPress('backspace'),
          ),
        )
        ..add(
          NumberKeyButton(
            number: 'Send',
            onPressed: () => onKeyPress('send'),
          ),
        ),
    );
  }
}

class NumberKeyButton extends StatelessWidget {
  final String number;
  final VoidCallback onPressed;

  NumberKeyButton({required this.number, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        number,
        style: const TextStyle(fontSize: 24.0),
      ),
    );
  }
}
