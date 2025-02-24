import 'package:hive/hive.dart';
import 'user_info.dart';

class DatabaseHelper {
  static const String _boxName = "user_info_box";

  // Open the Hive box
  static Future<Box<UserInfo>> getBox() async {
    return await Hive.openBox<UserInfo>(_boxName);
  }

  // Insert Data
  static Future<void> insertData(UserInfo user) async {
    final box = await getBox();
    await box.add(user);
  }

  // Get All Data
  static Future<List<UserInfo>> getAllData() async {
    final box = await getBox();
    return box.values.toList();
  }

  // Clear All Data
  static Future<void> clearData() async {
    final box = await getBox();
    await box.clear();
  }
}
