import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/Controller/security.dart';
import 'package:upbmining/Model/util_class.dart';
import '../hive/user_info.dart';
import 'package:share_plus/share_plus.dart';

class SyncProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // share data
  void shareData() {
    String message = "Unleash the Power of UPB and Earn Big! 🚀\n\n"
        "Earn effortlessly by referring friends to join the crypto revolution. 💰\n\n"
        "Here’s how it works:\n"
        "✅ Join the UPB community using your unique referral link\n"
        "✅ Earn rewards for every successful referral\n\n"
        "🔗 Join now: https://upbonline.com/Home/Register/UPB1W0ZRT22";

    Share.share(message);
  }

  /// Retrieve userId and token from SharedPreferences
  Future<Map<String, String>?> getSessionData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    String? token = prefs.getString("token");

    if (userId != null && token != null) {
      return {"userId": userId, "token": token};
    }
    return null;
  }

  /// Send Hive data to API
  Future<void> sendDataToApi(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Retrieve session
      Map<String, String>? session = await getSessionData();
      if (session == null ||
          !session.containsKey("userId") ||
          !session.containsKey("token")) {
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Session expired. Please log in again.')),
        );
        return;
      }

      String? userId = session["userId"];
      String? token = session["token"];

      if (userId == null || token == null) {
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid session data.')),
        );
        return;
      }

      // Ensure Hive is properly initialized
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserInfoAdapter());
      }

      // Retrieve stored user info from Hive
      final userInfoBox = await Hive.openBox<UserInfo>('userInfo');
      List<UserInfo> userInfoList = userInfoBox.values.toList();

      if (userInfoList.isEmpty) {
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to sync')),
        );
        return;
      }

      // Extract only required fields
      List<Map<String, dynamic>> filteredData = userInfoList
          .map((e) => {
                "accountNo": e.accountNo,
                "blovk": e.blovk,
                "reward": e.reward.toString(),
                "dateTime": e.dateTime.toString(),
              })
          .toList();
      print(">>>>>fetched date length ${filteredData.length}");

      // Convert filtered data to JSON
      String jsonData = jsonEncode(filteredData);
      print("\u{1F4CC} JSON Data Before Encryption: $jsonData");
      print(">>>>>>>>>>>>>>> jsondata length ${jsonData.length}");

      // Encrypt Data
      String encryptedData = AesEncryptionHelper.encryptData(jsonData);
      String base64Encrypted = base64Encode(utf8.encode(encryptedData));
      debugPrint("\u{1F512} Encrypted Data: $base64Encrypted");

// decrypytion
      String decryptedData = AesEncryptionHelper.decryptData(encryptedData);
      List<dynamic> jsonDecryptedData = jsonDecode(decryptedData);
      print("📩 Decrypted JSON Data: $jsonData");
      List<Map<String, dynamic>> formattedData =
          List<Map<String, dynamic>>.from(jsonDecryptedData);

      print("✅ Parsed JSON: ${formattedData.length}");

      // Generate authentication header
      String auth =
          "Basic " + base64Encode(utf8.encode("UPB_GetBuId:Upblogin%43@09_2"));
      print("Decrypted data ${AesEncryptionHelper.decryptData(encryptedData)}");

      // Construct API Request Payload
      final requestBody = base64Encrypted;
      final headers = {
        "Authorization": auth,
        // "Content-Type": "application/json",
        "UserId": userId,
        "Method": "GetById",
        "Token": token,
        "DeviceType": "Mobile",
        // "encryptedData": requestBody,
      };

      final url =
          Uri.parse('https://api.upbonline.com/api/User/CreateAppMining');

      // API Request
      final response = await http.post(
        url,
        headers: headers,
        body: {"encryptedData": requestBody},
      );

      debugPrint("\u{1F504} API Response Code: ${response.statusCode}");
      debugPrint("\u{1F4E5} API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        await userInfoBox.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data synced successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send data: ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint("\u{274C} Error: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
