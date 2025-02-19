import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upbmining/components/sync_popup.dart';
import 'package:provider/provider.dart';
import 'package:upbmining/Controller/coin_controller.dart';
import 'package:upbmining/components/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowPopup();
    });
  }

  /// Function to check if popup has already been shown today
  Future<void> checkAndShowPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Get the last shown date
    String? lastShownDate = prefs.getString('last_popup_date');
    String todayDate =
        DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format

    if (lastShownDate != todayDate) {
      // Show the popup since it's a new day
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false, // Prevents dismissing by tapping outside
          builder: (context) => const SyncPopup(),
        );
      });

      // Save the new date
      await prefs.setString('last_popup_date', todayDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoinController>(builder: (context, coin, _) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          backgroundColor: Colors.white,
        ),
        drawer: const CustomDrawer(),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.5), // Semi-transparent background
                builder: (context) => const SyncPopup(),
              );
            },
            child: const Text("Sync"),
          ),
        ),
      );
    });
  }
}
