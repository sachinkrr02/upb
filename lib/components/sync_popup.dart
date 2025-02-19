import 'package:flutter/material.dart';

class SyncPopup extends StatelessWidget {
  const SyncPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          const Icon(Icons.sync, color: Colors.blue),
          const SizedBox(width: 10),
          const Text("Sync Your Coins"),
        ],
      ),
      content: const Text(
        "Your coins are being synchronized. Please wait...",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
