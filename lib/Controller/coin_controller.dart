import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/components/sync_popup.dart';
import 'package:upbmining/hive/boxes.dart';

class CoinController extends ChangeNotifier {
  int coinValue = 0;
  String _generatedCode = '';
  String _binaryOutput = '';

  String get generatedCode => _generatedCode;
  String get binaryOutput => _binaryOutput;

  void refreshCoin() {
    coinValue += 4;
    notifyListeners();
  }

  Future<void> clearHiveDatabase(BuildContext context) async {
    try {
      userInfo.clear(); // Clear the data
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hive database cleared successfully')));
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear database: $e')));
    }
  }

  // Function to generate the random number and binary output
  void generateNumber() {
    List<String> randomAlphabets = [];
    Random random = Random();
    StringBuffer generatedCodeBuffer = StringBuffer();

    // Step 1: Generate 64 random uppercase alphabets
    for (int i = 0; i < 64; i++) {
      String randomChar = String.fromCharCode(
          random.nextInt(26) + 65); // Generate random uppercase alphabet
      randomAlphabets.add(randomChar);
      generatedCodeBuffer
          .write(randomChar); // Append character to generated code
    }

    _generatedCode = generatedCodeBuffer.toString();

    // Step 2: Convert each alphabet to its binary representation and group them into combined 8-bit strings
    StringBuffer binaryGroup = StringBuffer();

    for (int i = 0; i < randomAlphabets.length; i++) {
      int asciiValue = randomAlphabets[i].codeUnitAt(0);
      String binaryString =
          asciiValue.toRadixString(2).padLeft(8, '0'); // Format to 8-bit binary

      // Append each binary string to the current group
      binaryGroup.write(binaryString);

      // If 4 alphabets are combined, append the group to the output and reset for the next 4
      if ((i + 1) % 4 == 0) {
        binaryGroup.write('\n'); // Add a new line after every 4 binary strings
      }
    }

    _binaryOutput = binaryGroup.toString();

    // Notify listeners about the change
    notifyListeners();
  }

  // sync remainder
  Future<void> checkAndShowPopup(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the last shown date
    String? lastShownDate = prefs.getString('last_popup_date');
    String todayDate =
        DateTime.now().toString().split(' ')[0]; // Get YYYY-MM-DD

    if (lastShownDate != todayDate) {
      // Show the popup since it's a new day
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => const SyncPopup(),
        );
      });

      // Save the new date
      await prefs.setString('last_popup_date', todayDate);
    }
  }
  //

  
}
