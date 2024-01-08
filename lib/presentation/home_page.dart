import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'deteksi_method/captcha_method.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Beranda",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DashboardScreen()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard),
                    SizedBox(width: 20),
                    Text("DashBoard"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showCaptchaDialog(context);
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => const DeteksiWajahView()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera),
                    SizedBox(width: 10),
                    Text("Deteksi Wajah"),
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

//   void showCaptchaDialog(BuildContext context) {
//     final captchaData = generateCaptcha();
//     final captcha = captchaData['captcha'];
//     final answer = captchaData['answer'];

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('CAPTCHA Verification'),
//           content: Column(
//             children: [
//               Text(captcha),
//               TextField(
//                 decoration:
//                     const InputDecoration(labelText: 'Enter your answer'),
//                 keyboardType: TextInputType.number,
//                 onSubmitted: (String value) {
//                   // Navigator.of(context).pop();
//                   verifyCaptcha(context, value, answer);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void verifyCaptcha(BuildContext context, String userAnswer, int answer) {
//     if (int.tryParse(userAnswer) == answer) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('CAPTCHA Passed'),
//             content: Column(
//               children: [
//                 const Text('You have successfully passed the CAPTCHA.'),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => const DeteksiWajahView()));
//                   },
//                   child: const Text("Ok"),
//                 )
//               ],
//             ),
//           );
//         },
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('CAPTCHA Failed'),
//             content: Container(
//                 child: Column(
//               children: [
//                 const Text('The answer is incorrect. Please try again.'),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text("Ok"),
//                 )
//               ],
//             )),
//           );
//         },
//       );
//     }
//   }

//   Map<String, dynamic> generateCaptcha() {
//     final Random random = Random();
//     final int a = random.nextInt(10);
//     final int b = random.nextInt(10);
//     final String operator = ['+', '-', '*'][random.nextInt(3)];
//     final String captcha = '$a $operator $b = ?';
//     final int answer = _calculateAnswer(a, b, operator);
//     return {'captcha': captcha, 'answer': answer};
//   }

//   int _calculateAnswer(int a, int b, String operator) {
//     switch (operator) {
//       case '+':
//         return a + b;
//       case '-':
//         return a - b;
//       case '*':
//         return a * b;
//       default:
//         return 0;
//     }
//   }
// }
