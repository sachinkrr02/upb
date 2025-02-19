import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/Login/login.dart';
import 'package:upbmining/hive/boxes.dart';
import 'api_service.dart';

class LoginController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  String? message;
  bool isDataSynced = false;
  String? userId; // Store user ID after login
  String? token; // Store the API token

  // Login function
  Future<void> login(
      String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final response = await _apiService.login(email, password);

    isLoading = false;
    if (response != null && response.method == "True") {
      message = response.message;
      userId = response.userId.toString(); // Store User ID after login
      notifyListeners();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.message)));

      // Fetch token after successful login
      await fetchTokenAfterLogin(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login Failed")));
    }
  }

  /// logout function
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear session data

    // Navigate to Login Screen and remove all previous screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // Clear back stack
    );

    // Show Snackbar for feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You have been logged out")),
    );

    notifyListeners();
  }

  void clearHive() {
    try {
      userInfo.clear();
      // userInfo.close();
      debugPrint("Hive database cleared successfully.");
    } catch (e) {
      debugPrint("Error clearing Hive database: $e");
    }
  }

  // Fetch Token by UserId
  Future<void> fetchTokenAfterLogin(BuildContext context) async {
    if (userId == null) {
      print("UserId is null. Cannot fetch token.");
      return;
    }

    isLoading = true;
    notifyListeners();

    final response = await _apiService.getTokenByUserId(userId!);

    isLoading = false;
    if (response != null) {
      token = response; // Store the token
      notifyListeners();

      debugPrint(token);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Token Retrieved: $token")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to fetch token")));
    }
  }

  // Method to fetch data from Hive and send it to the API
  Future<void> sendDataController(BuildContext context) async {
    // Start loading state
    isLoading = true;
    isDataSynced = false; // Reset sync status before attempting to sync
    notifyListeners();

    try {
      // Call the API and store the response
      final response = await _apiService.sendDataToApi(context);

      // Ensure context is still valid before interacting with UI
      if (!context.mounted) return;

      if (response == 200) {
        isDataSynced = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data synced successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sync failed: response")),
        );
      }
    } catch (e) {
      debugPrint("An error occurred: $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } finally {
      // Stop loading in any case (success or failure)
      isLoading = false;
      notifyListeners();
    }
  }
}
