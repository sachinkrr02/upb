import 'package:flutter/material.dart';
import 'dart:async';

import 'package:upbmining/Login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer to automatically navigate to the next screen after a delay
    Timer(const Duration(seconds: 3), () {
      // Navigate to the next screen (replace 'HomePage' with your target screen)
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF11150F),
      body: Padding(
        padding: EdgeInsets.only(top: 200),
        child: Column(
          children: [
            // Center(
            //   child: Lottie.asset(
            //     'assets/animation/animation_blockchain.json', // Replace with your image path
            //
            //   ),
            // ),
            Text(
              'Your Secure Crypto Wallet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
