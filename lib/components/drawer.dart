import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upbmining/Controller/coin_controller.dart';
import 'package:upbmining/Controller/device_info.dart';
import 'package:upbmining/Controller/login_controller.dart';
import 'package:upbmining/hive/boxes.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoginController, CoinController, DeviceInfoProvider>(
      builder: (context, loginController, coinProvider, deviceinfoProvider, _) {
        return Drawer(
          backgroundColor: Colors.blue,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/upb_logo.png", // Change to your image path
                      height: 50,
                      width: 90,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    const Text("UPB1W0ZRT22",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    const Text("Hi! Praveen Kumar",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCoinCard(coinProvider.coinValue, "Total"),
                  _buildCoinCard(150,
                      "Refferal"), // Hardcoded value, replace with dynamic if needed
                ],
              ),
              const SizedBox(height: 10),
              _buildMiningStatsContainer(deviceinfoProvider),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // loginController.clearHive();
                    loginController.sendDataController(context);
                    // var box = Hive.box('UserInfo');
                    // box.deleteFromDisk();
                    // box.close();
                    // coinProvider.clearHiveDatabase(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: const Text(
                    "Sync",
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
              Column(
                children: [
                  _imageContainer(
                    "RAM Utilization",
                    "assets/images/ram_bg.png",
                    _parseRam(deviceinfoProvider.ram),
                    _parseRam(deviceinfoProvider.ram),
                  ),
                  _imageContainer(
                    "CPU Utilization",
                    "assets/images/cpu_bg1.png",
                    (deviceinfoProvider.cpuCores / 2).toInt(),
                    deviceinfoProvider.cpuCores,
                  ),
                  _imageContainer(
                    "GPU Utilization",
                    "assets/images/gpu_bg.png",
                    (deviceinfoProvider.gpuCores / 2).toInt(),
                    deviceinfoProvider.gpuCores,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 88),
                child: ElevatedButton(
                  onPressed: () {
                    // Logout action yahan likhein
                    loginController.logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Logout",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build the coin cards
  Widget _buildCoinCard(int value, String label) {
    return Container(
      width: 120,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/images/dollar_symbol.png",
              height: 25,
              width: 25,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Text(value.toString()),
                Text(label),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Helper method to build mining stats container
  Widget _buildMiningStatsContainer(DeviceInfoProvider deviceinfoProvider) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatsColumn("Total", 9692),
          _buildStatContainer("Today", 216),
          _buildStatContainer("Week", 372),
          _buildStatContainer("Month", 372),
        ],
      ),
    );
  }

  // Helper method for displaying stats
  Widget _buildStatsColumn(String label, int value) {
    return Column(
      children: [
        Text(value.toString(), style: const TextStyle(fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatContainer(String label, int value) {
    return Container(
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, textAlign: TextAlign.center),
          Text(value.toString(), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Safe parsing function for RAM
  int _parseRam(String ram) {
    if (ram == "Unknown") {
      return 0; // Default value when the RAM is unknown
    }
    final match = RegExp(r'\d+').firstMatch(ram);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }
    return 0;
  }
}

Widget _imageContainer(String text, String imagePath, int filled, int total) {
  if (total == 0) {
    total = 1; // Default to 1 to avoid division by zero
  }

  double progress =
      (filled / total).clamp(0.0, 1.0); // Clamping to avoid NaN or infinity

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Stack(
      children: [
        // Background Image
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // Left Side Text
        Positioned(
          left: 16,
          top: 16,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Right Side Circular Progress with Text
        Positioned(
          right: 16,
          top: 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress, // Progress Value
                  strokeWidth: 5,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              Text(
                "$filled/$total", // Dynamic Text inside Circle
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
