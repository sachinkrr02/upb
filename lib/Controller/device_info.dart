import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';

class DeviceInfoProvider extends ChangeNotifier {
  int _totalRam = 0;
  int _cpuCores = 0;
  int _gpuCores = 0;

  int get totalRam => _totalRam; // Returns Total RAM in MB
  int get cpuCores => _cpuCores; // Returns CPU Core Count
  int get gpuCores => _gpuCores; // Returns GPU Core Count (Estimated)

  DeviceInfoProvider() {
    fetchDeviceInfo();
  }

  Future<void> fetchDeviceInfo() async {
    try {
      // 1️⃣ Fetch CPU Cores
      _cpuCores = Platform.numberOfProcessors;

      // 2️⃣ Fetch RAM in MB (For Android, Linux)
      _totalRam = (SysInfo.getTotalPhysicalMemory() / (1024 * 1024)).round();

      // 3️⃣ Fetch GPU Cores (No direct API in Flutter, estimated as 2/3 of CPU)
      _gpuCores = (_cpuCores * 0.6).toInt(); // Approximation

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching device info: $e");
    }
  }
}
