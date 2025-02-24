import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:upbmining/Controller/coin_controller.dart';
import 'package:upbmining/Controller/device_info.dart';
import 'package:upbmining/Controller/login_controller.dart';
import 'package:upbmining/Controller/syncCoin.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LoginController, DeviceInfoProvider, SyncProvider>(
      builder: (context, loginController, deviceInfoProvider, coinSync, _) {
        var data = context.watch<LoginController>().userData;
        return Drawer(
          backgroundColor: Colors.blue,
          child: ListView(
            // padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/upb_logo.png",
                      // height: 50,
                      // width: 90,
                      // fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text(data['uniqueId'].toString(),
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('Hi! ${data['name']}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Consumer<CoinController>(builder: (context, coinProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
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
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                Text("Validator\nReward"),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    _buildCoinCard("0", "Referral", () {
                      _shareAppInfo();
                    }),
                  ],
                );
              }),
              const SizedBox(height: 30),
              Consumer<CoinController>(builder: (context, coinProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCoinCard((data['total'] ?? "0"), "Total", () {
                      print("Total");
                    }),
                    _buildCoinCard(coinProvider.coinValue.toString(), "Sync",
                        () {
                      print("Sync");
                    }),
                  ],
                );
              }),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await coinSync.sendDataToApi(context);
                      // coinSync.appmining();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data synced successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sync failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
                      (deviceInfoProvider.totalRam / 2).toInt(),
                      deviceInfoProvider.totalRam),
                  _imageContainer(
                    "CPU Utilization",
                    "assets/images/cpu_bg1.png",
                    (deviceInfoProvider.cpuCores / 2).toInt(),
                    deviceInfoProvider.cpuCores,
                  ),
                  _imageContainer(
                    "GPU Utilization",
                    "assets/images/gpu_bg.png",
                    (deviceInfoProvider.gpuCores / 2).toInt(),
                    deviceInfoProvider.gpuCores,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 88),
                child: ElevatedButton(
                  onPressed: () {
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

  Widget _buildCoinCard(String value, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value),
                    Text(label),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAppInfo() {
    Share.share(
        "Hey! Check out this amazing app: UPB Mining. Download now: https://play.google.com/store/apps/details?id=com.upbmining.app",
        subject: "UPB Mining - Earn Rewards!");
  }

  Widget _imageContainer(String text, String imagePath, int filled, int total) {
    total = total == 0 ? 1 : total;
    double progress = (filled / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
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
          Positioned(
            right: 16,
            top: 16,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
