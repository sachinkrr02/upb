import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/Login/login.dart';
import 'package:upbmining/hive/boxes.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;

class LoginController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  String? message;
  bool isDataSynced = false;
  String? _userId;
  String? _token;

  String? get userId => _userId;
  String? get token => _token;
  Map<String, dynamic> _userData = {};

  Map<String, dynamic> get userData => _userData;

  // // ✅ Fetch user details by ID
  // Future<void> getById(String userId) async {
  //   try {
  //     if (_token == null) {
  //       debugPrint("❌ Token is null. Cannot fetch user.");
  //       return;
  //     }

  //     final headers = {
  //       'UserId': userId,
  //       'Method': 'GetById',
  //       'Token': _token ?? '',
  //       'DeviceType': 'Mobile',
  //       'Authorization': 'Basic VVBCX0dldEJ1SWQ6VXBibG9naW4lNDNAMDlfMg==',
  //     }..removeWhere((key, value) => value!.isEmpty);

  //     final url = Uri.parse('https://api.upbonline.com/api/User/GETBYID');
  //     final response = await http.post(url, headers: headers);

  //     if (response.statusCode == 200) {
  //       debugPrint("✅ User Data:\n${jsonEncode(jsonDecode(response.body))}");
  //     } else {
  //       debugPrint("❌ API Error: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     debugPrint("🚨 Exception in getById(): $e");
  //   }
  // }

  Future<void> fetchUserById() async {
    const String url = "https://api.upbonline.com/api/User/GETBYID";
    String auth =
        "Basic ${base64Encode(utf8.encode("UPB_GetBuId:Upblogin%43@09_2"))}";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': auth,
          "userid": _userId!,
          "method": "GetById",
          "token": token!,
          "DeviceType": "Mobile",
        },
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body);
        print("User Data login: ${_userData}");
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
    notifyListeners();
  }

  // ✅ Login function
  Future<void> login(
      String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiService.login(email, password);

    isLoading = false;
    if (response != null && response.method == "True") {
      message = response.message;
      _userId = response.userId.toString();
      notifyListeners();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.message)));

      await fetchTokenAfterLogin(context); // Fetch token
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login Failed")));
    }
  }

  // ✅ Logout function
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _userId = null;
    _token = null;
    notifyListeners();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have been logged out")));
  }

  // ✅ Load session from SharedPreferences
  Future<void> loadSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString("userId");
    _token = prefs.getString("token");
    notifyListeners();
  }

  // ✅ Save session to SharedPreferences
  Future<void> saveLoginSession(String userId, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", userId);
    await prefs.setString("token", token);

    _userId = userId;
    _token = token;
    notifyListeners();
  }

  // ✅ Clear Hive database
  void clearHive() {
    try {
      userInfo.clear();
      debugPrint("✅ Hive database cleared successfully.");
    } catch (e) {
      debugPrint("❌ Error clearing Hive database: $e");
    }
  }

  // ✅ Fetch Token by UserId
  Future<void> fetchTokenAfterLogin(BuildContext context) async {
    if (_userId == null) {
      debugPrint("❌ UserId is null. Cannot fetch token.");
      return;
    }

    isLoading = true;
    notifyListeners();

    final response = await _apiService.getTokenByUserId(_userId!);

    isLoading = false;
    if (response != null) {
      _token = response;
      notifyListeners();

      debugPrint("✅ Token Retrieved: $_token");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Token Retrieved: $_token")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to fetch token")));
    }
  }

  // ✅ Send Hive data to API
  Future<void> sendDataController(BuildContext context) async {
    isLoading = true;
    isDataSynced = false;
    notifyListeners();

    try {
      final response = await _apiService.sendDataToApi(context);

      if (!context.mounted) return;

      if (response == 200) {
        isDataSynced = true;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data synced successfully")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Sync failed: $response")));
      }
    } catch (e) {
      debugPrint("❌ Error in sendDataController: $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("An error occurred: $e")));
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
