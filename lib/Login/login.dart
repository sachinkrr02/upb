import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/Controller/api_service.dart';
import 'package:upbmining/Controller/login_controller.dart';
import 'package:upbmining/Home/Homepage.dart';
import 'package:upbmining/Login/Register.dart';
import 'package:upbmining/Login/forgotpass.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  TextEditingController accountNo = TextEditingController();
  TextEditingController password = TextEditingController();

  /// **Save login session in SharedPreferences**
  Future<void> saveLoginSession(String userId, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("userId", userId);
    await prefs.setString("token", token);

    debugPrint("Saved UserId: ${prefs.getString("userId")}");
    debugPrint("Saved Token: ${prefs.getString("token")}");
  }

  /// **Handle login button click**
  void handleLogin() async {
    final apiService = ApiService();
    final response = await apiService.login(accountNo.text, password.text);

    if (response != null && response.userId != null) {
      debugPrint("Login Successful: ${response.message}");

      String? token =
          await apiService.getTokenByUserId(response.userId.toString());

      if (token != null) {
        debugPrint("Token Retrieved: $token");

        // Save session in SharedPreferences
        await saveLoginSession(response.userId.toString(), token);

        // Use AuthProvider to update state
        Provider.of<LoginController>(context, listen: false)
            .saveLoginSession(response.userId.toString(), token);

        // Navigate to Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        debugPrint("Failed to fetch token");
        showSnackBar("Failed to retrieve token");
      }
    } else {
      debugPrint("Login Failed");
      showSnackBar("Login Failed");
    }
  }

  /// **Show error messages**
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(builder: (context, login, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Secure Sign-In",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Access Your Account with UPB A/C Number and Password",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: accountNo,
                      decoration: const InputDecoration(
                        labelText: "Account No",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: password,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ));
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
