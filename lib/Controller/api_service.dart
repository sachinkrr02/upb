import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart'; // For Hive database
import 'package:crypto/crypto.dart'; // For encryption (SHA-256)
import 'package:upbmining/hive/boxes.dart';
import 'dart:typed_data';

import '../Model/login_model.dart';
import '../Model/app_mining.dart'; // Assuming your AppMining model is here

class ApiService {
  // Base URL for the API
  static const String baseUrl = "https://api.upbonline.com/api";

  // Method to perform the login API call
  Future<LoginResponse?> login(String email, String password) async {
    final String endpoint = "/Login/GetLogin"; // Separate endpoint

    final headers = {
      'Method': 'Login',
      'Email': email,
      'Password': password,
      'Authorization': 'Basic VVBCX0xvZ2luOlVwYmxvZ2luJTQzQDA5',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint), // Combine baseUrl and endpoint
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }

  // Function to get token by UserId
  Future<String?> getTokenByUserId(String userId) async {
    final url = Uri.parse(
        "https://api.upbonline.com/api/Generic/CreateTokenByUserId?Method=GetBYid");

    try {
      final response = await http.get(
        url,
        headers: {"UserId": userId}, // Sending UserId in headers
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // Adjust based on API response structure
      } else {
        print("Failed to fetch token: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching token: $e");
    }
    return null;
  }

  // Method to fetch data from Hive and send it to the API
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
        return 204; // No data to sync (HTTP 204 No Content)
      }

      // Convert the list to JSON format
      String appMiningListJson = jsonEncode(appMiningList);

      // Encrypt the data
      String encryptedData = _encryptData(appMiningListJson);

      // Prepare the API request
      String auth =
          "Basic ${base64Encode(utf8.encode("UPB_GetBuId:Upblogin%43@09_2"))}";
      Uri apiUrl = Uri.parse('$baseUrl/User/CreateAppMining');

      // Send the data to the API
      final response = await http.post(
        apiUrl,
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/json',
          'UserId': 'UPB1W0ZRT22',
          'Method': 'GetById',
          'Token': 'bXl4eEZDczQ=',
          'DeviceType': 'Mobile',
        },
        body: jsonEncode({'encryptedData': encryptedData}),
      );

      if (response.statusCode == 200) {
        debugPrint(encryptedData);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data synced successfully")),
          );
        }

        // Optionally, clear Hive data after successful sync
        await userInfo.clear();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to send data")));
        }
      }

      return response.statusCode; // Return the status code
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("An error occurred: $e")));
      }
      return 500; // Return HTTP 500 Internal Server Error
    }
  }

  // Helper function to encrypt data (SHA-256)
  String _encryptData(String data) {
    // Convert the string data to bytes
    List<int> bytes = utf8.encode(data);

    // Apply SHA-256 hash
    var digest = sha256.convert(bytes);
    // debugPrint("bbfuduhgh ${digest.toString()}");
    // Return the hexadecimal string representation of the hash
    return digest.toString();
  }
}
