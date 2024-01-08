import 'dart:math';

import 'package:face_rec/presentation/deteksi_page.dart';
import 'package:flutter/material.dart';

void showCaptchaDialog(BuildContext context) {
  final captchaData = generateCaptcha();
  final captcha = captchaData['captcha'];
  final answer = captchaData['answer'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('CAPTCHA Verification'),
        content: Container(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(captcha),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Enter your answer'),
                keyboardType: TextInputType.number,
                onSubmitted: (String value) {
                  Navigator.of(context).pop();
                  verifyCaptcha(context, value, answer);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void verifyCaptcha(BuildContext context, String userAnswer, int answer) {
  if (int.tryParse(userAnswer) == answer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CAPTCHA Passed'),
          content: Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have successfully passed the CAPTCHA.'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const DeteksiWajahView()));
                  },
                  child: const Text("ok"),
                )
              ],
            ),
          ),
        );
      },
    );
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CAPTCHA Failed'),
          content: Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('The answer is incorrect. Please try again.'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Ok"),
                  )
                ],
              )),
        );
      },
    );
  }
}

Map<String, dynamic> generateCaptcha() {
  final Random random = Random();
  final int a = random.nextInt(10);
  final int b = random.nextInt(10);
  final String operator = ['+', '-', '*'][random.nextInt(3)];
  final String captcha = '$a $operator $b = ?';
  final int answer = _calculateAnswer(a, b, operator);
  return {'captcha': captcha, 'answer': answer};
}

int _calculateAnswer(int a, int b, String operator) {
  switch (operator) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    default:
      return 0;
  }
}
