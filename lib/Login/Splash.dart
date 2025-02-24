import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:upbmining/Home/Homepage.dart';
import 'package:upbmining/Login/login.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String currentVersion = "1.0.3"; // App's current version

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    final headers = {
      'Method': 'Reg',
      'Authorization': 'Basic VVBCX1JlZzpVcGJSZWclNDNAMDlfMQ=='
    };
    final url = Uri.parse('https://api.upbonline.com/api/User/GETAppVersion');

    try {
      final res = await http.get(url, headers: headers);
      debugPrint("Response Status Code: ${res.statusCode}");
      debugPrint("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        String latestVersion = data["latestVersion"] ?? "";
        bool forceUpdate = data["forceUpdate"] ?? false;

        if (latestVersion.isEmpty) {
          debugPrint("Invalid version received");
          checkLoginStatus();
          return;
        }

        if (latestVersion == currentVersion) {
          checkLoginStatus(); // Check login after version check
        } else {
          showUpdateDialog(forceUpdate);
        }
      } else {
        debugPrint("API error: ${res.statusCode} - ${res.body}");
        checkLoginStatus();
      }
    } on SocketException {
      debugPrint("No internet connection.");
      checkLoginStatus();
    } on FormatException {
      debugPrint("Invalid response format.");
      checkLoginStatus();
    } catch (e) {
      debugPrint("Unexpected error: $e");
      checkLoginStatus();
    }
  }

  /// **Check if the user is already logged in**
  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String? userId = prefs.getString('userId');
      String? token = prefs.getString('token');

      debugPrint("User is logged in: $userId");
      debugPrint("Token: $token");

      // Navigate to HomePage if logged in
      navigateToPage(const HomePage());
    } else {
      debugPrint("User is NOT logged in");
      navigateToPage(const LoginPage());
    }
  }

  /// **Navigate to the next screen**
  void navigateToPage(Widget page) {
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => page),
      );
    });
  }

  void showUpdateDialog(bool forceUpdate) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Available"),
          content: const Text("A new version is available. Please update."),
          actions: [
            TextButton(
              onPressed: launchPlayStore,
              child: const Text("Update"),
            ),
            if (!forceUpdate)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  checkLoginStatus(); // Check login status after dismissing
                },
                child: const Text("Remind Me Later"),
              ),
          ],
        );
      },
    );
  }

  void launchPlayStore() async {
    const playStoreUrl =
        "https://play.google.com/store/apps/details?id=com.upbmining";
    if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
      await launchUrl(Uri.parse(playStoreUrl));
    } else {
      debugPrint("Could not launch Play Store");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 200),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/bg1.png',
                height: 200,
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'UPB Block Validator',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
