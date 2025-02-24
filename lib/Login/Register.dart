import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Home/Homepage.dart';
import '../Login/login.dart';
import 'package:country_code_picker/country_code_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  CountryCode _selectedCountry = CountryCode.fromCountryCode('IN');

  // Controllers for input fields
  final TextEditingController _sponsorController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  // Function to show a snackbar with a message
  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Sponsor Code Validation (Modify this regex as per requirement)
  bool _isValidSponsorCode(String code) {
    return code.startsWith("UPB") && code.length == 11;
  }

  // Email Validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  // Mobile Number Validation (Modify this as per country format)
  bool _isValidMobile(String number) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(number); // Indian number format
  }

  // API Call Function
  Future<void> _registerUser() async {
    // Prevent API call if any field is empty
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _sponsorController.text.isEmpty) {
      _showMessage("Please fill all fields.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final headers = {
      'Method': 'Reg',
      'Content-Type': 'application/json',
      'Authorization': 'Basic VVBCX1JlZzpVcGJSZWclNDNAMDlfMQ==',
    };

    final data = jsonEncode({
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "mobile": _mobileController.text.trim(),
      "country": _selectedCountry,
      "refCode": _sponsorController.text.trim(),
    });

    final url =
        Uri.parse('https://api.upbonline.com/api/Registration/Registration');

    try {
      final res = await http.post(url, headers: headers, body: data);
      final status = res.statusCode;

      if (status == 200) {
        _showMessage("Registration successful!", isError: false);

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomePage(),
        ));
      } else {
        // Decode response and display the API error message
        final Map<String, dynamic> responseBody = jsonDecode(res.body);
        String errorMessage =
            responseBody["message"] ?? "Something went wrong!";
        _showMessage("Error: $errorMessage");
      }
    } on SocketException {
      _showMessage("No internet connection. Please check your network.");
    } on FormatException {
      _showMessage("Invalid response format. Please try again later.");
    } catch (e) {
      _showMessage("An unexpected error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // const SizedBox(height: 5),
                    const Text(
                      "Create New Account",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _sponsorController,
                      decoration: const InputDecoration(
                        labelText: "Sponsor's UPB A/C Number",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Sponsor code is required";
                        }
                        if (!_isValidSponsorCode(value)) {
                          return "Invalid sponsor code";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Full Name is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!_isValidEmail(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Referral Code",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.share),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (country) {
                            setState(() {
                              _selectedCountry = country;
                            });
                            debugPrint(
                                "Selected Country: ${country.name}, Code: ${country.dialCode}");
                          },
                          initialSelection: 'IN', // Default country
                          showCountryOnly: true,
                          showOnlyCountryWhenClosed: false,
                          showFlag: true,
                          // alignLeft: false,
                          // showDropDownButton: true,
                        ),
                        // Space between country picker and text field
                        Expanded(
                          child: TextFormField(
                            controller: _mobileController,
                            decoration: const InputDecoration(
                              labelText: "Mobile Number",
                              border: OutlineInputBorder(),
                              // prefixIcon: _selectedCountry.flagUri != null
                              //     ? Padding(
                              //         padding: const EdgeInsets.all(8.0),
                              //         child: Image.asset(
                              //           _selectedCountry.flagUri!,
                              //           package:
                              //               'country_code_picker', // Required for package assets
                              //           width: 24,
                              //           height: 24,
                              //         ),
                              //       )
                              //     : const Icon(Icons
                              //         .phone), // Fallback icon if flag is missing
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Mobile number is required";
                              }
                              if (!_isValidMobile(value)) {
                                return "Enter a valid 10-digit mobile number";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Sign Up",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                      },
                      child: const Text(
                        "Already have an account? Sign In",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
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
