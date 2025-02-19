// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:system_info2/system_info2.dart';

// class DeviceInfoProvider with ChangeNotifier {
//   String _cpu = "Unknown";
//   int _cpuCores = 0;
//   int _gpuCores = 0;
//   int _ram = 0; // Store RAM as bytes

//   String get cpu => _cpu;
//   int get cpuCores => _cpuCores;
//   int get gpuCores => _gpuCores;
//   int get ram => _ram;

//   Future<void> fetchDeviceInfo() async {
//     try {
//       if (Platform.isAndroid) {
//         await _getAndroidInfo();
//       } else if (Platform.isIOS) {
//         await _getIosInfo();
//       } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
//         await _getDesktopInfo();
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error fetching device info: $e");
//     }
//   }

//   Future<void> _getAndroidInfo() async {
//     final deviceInfo = await DeviceInfoPlugin().androidInfo;
//     _cpu = deviceInfo.hardware ?? "Unknown CPU";
//     _cpuCores = deviceInfo.cpuCores ?? 0; // Number of CPU cores (Android)
//     _gpuCores = await _getGpuCores(); // Number of GPU cores (approximate)
//     _ram = SysInfo.getTotalPhysicalMemory(); // RAM in bytes
//   }

//   Future<void> _getIosInfo() async {
//     final deviceInfo = await DeviceInfoPlugin().iosInfo;
//     _cpu = deviceInfo.utsname.machine ?? "Unknown CPU";
//     _cpuCores = deviceInfo.cpuCores ?? 0; // Number of CPU cores (iOS)
//     _gpuCores = await _getGpuCores();
//     _ram = SysInfo.getTotalPhysicalMemory(); // RAM in bytes
//   }

//   Future<void> _getDesktopInfo() async {
//     _cpu = SysInfo.kernelName;
//     _cpuCores = Platform.numberOfProcessors; // Number of CPU cores (Desktop)
//     _gpuCores = await _getGpuCores();
//     _ram = SysInfo.getTotalPhysicalMemory(); // RAM in bytes
//   }

//   Future<int> _getGpuCores() async {
//     // NOTE: Flutter currently lacks direct GPU core count access.
//     // Here is a mock function. For Android/iOS, use platform channels.
//     if (Platform.isAndroid) {
//       return 8; // Approximate for most modern mobile GPUs (Adreno, Mali)
//     } else if (Platform.isIOS) {
//       return 4; // Approximate for Apple GPUs (depends on A-series chip)
//     } else {
//       return 16; // Approximate for a desktop/laptop GPU
//     }
//   }

//   // Optional method to convert RAM to GB for display
//   String get ramInGB => (_ram / 1073741824).toStringAsFixed(2); // Convert to GB
// }
