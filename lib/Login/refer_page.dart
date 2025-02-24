import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferScreen extends StatelessWidget {
  final String? referralCode;

  const ReferScreen({Key? key, this.referralCode}) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    if (referralCode != null) {
      Clipboard.setData(ClipboardData(text: referralCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Referral Code Copied!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Navigated to ReferScreen with Referral Code: $referralCode");

    return Scaffold(
      appBar: AppBar(title: const Text("Refer & Earn")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Your Referral Code:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              referralCode ?? "No Code Found",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _copyToClipboard(context),
              icon: const Icon(Icons.copy),
              label: const Text("Copy Code"),
            ),
          ],
        ),
      ),
    );
  }
}
