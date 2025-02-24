import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:upbmining/Controller/security.dart';
import 'package:upbmining/Model/util_class.dart';
import 'package:upbmining/hive/boxes.dart';
import '../Model/login_model.dart';
import '../Model/app_mining.dart';

class ApiService {
  static const String baseUrl = "https://api.upbonline.com/api";

  /// **🔹 Login API**
  Future<LoginResponse?> login(String email, String password) async {
    final String endpoint = "/Login/GetLogin";

    final headers = {
      'Method': 'Login',
      'Email': email,
      'Password': password,
      'Authorization': 'Basic VVBCX0xvZ2luOlVwYmxvZ2luJTQzQDA5',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        debugPrint("❌ Login failed Api: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("🚨 Login error: $e");
      return null;
    }
  }

  /// **🔹 Fetch Token by UserId**
  Future<String?> getTokenByUserId(String userId) async {
    final url =
        Uri.parse("$baseUrl/Generic/CreateTokenByUserId?Method=GetById");

    try {
      final response = await http.get(url, headers: {"UserId": userId});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // Adjust according to API response structure
      } else {
        debugPrint("❌ Failed to fetch token: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Error fetching token: $e");
    }
    return null;
  }

// fetch by id

  // Future<void> fetchUserById({
  //   required String userId,
  //   required String method,
  //   required String token,
  // }) async {
  //   const String url = "https://api.upbonline.com/api/User/GETBYID";
  //   String auth =
  //       "Basic ${base64Encode(utf8.encode("UPB_GetBuId:Upblogin%43@09_2"))}";

  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Authorization': auth,
  //         "userid": userId,
  //         "method": method,
  //         "token": token,
  //         "DeviceType": "Mobile",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("User Data api: $data");
  //     } else {
  //       print("Error: ${response.statusCode} - ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //   }
  // }

  Future<int> sendDataToApi(BuildContext context) async {
    try {
      List<AppMining> appMiningList = [];

      // Fetch all data from Hive
      for (var key in userInfo.keys) {
        var appMining = AppMining.fromJson(userInfo.get(key));
        appMiningList.add(appMining);
      }

      if (appMiningList.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("No data to sync")));
        }
        return 204; // No Content
      }

      // Convert the list to JSON format
      String appMiningListJson = jsonEncode(appMiningList);
      debugPrint("📌 AppMining List JSON: $appMiningListJson");

      // Encrypt the data
      String encryptedData = AesEncryptionHelper.encryptData(appMiningListJson);
      print("🔐 Encrypted Data: $encryptedData");

      if (encryptedData.isEmpty) {
        debugPrint("❌ Encryption failed.");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Encryption failed.")));
        }
        return 400;
      }

      // Fetch the token dynamically
      String userId = 'UPB1W0ZRT22'; // Update with actual user ID logic
      String? token = await getTokenByUserId(userId);

      if (token == null) {
        debugPrint("❌ Failed to fetch token. Aborting request.");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Token fetch failed.")));
        }
        return 401; // Unauthorized
      }

      // Prepare API request
      String auth =
          "Basic ${base64Encode(utf8.encode("UPB_GetBuId:Upblogin%43@09_2"))}";
      Uri apiUrl = Uri.parse('$baseUrl/User/CreateAppMining');

      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/json',
          'UserId': userId,
          'Method': 'GetById',
          'Token': token,
          'DeviceType': 'Mobile',
        },
        body: jsonEncode({
          "encryptedData": encryptedData,
        }),
      );

      debugPrint("📌 API Response Status Code: ${response.statusCode}");
      debugPrint("📌 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Data sent successfully.");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data synced successfully")));
        }
        await userInfo.clear();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("❌ Failed to send data: ${response.body}")));
        }
      }

      return response.statusCode;
    } catch (e) {
      debugPrint("🚨 Error sending data: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("❌ An error occurred: $e")));
      }
      return 500;
    }
  }
}
