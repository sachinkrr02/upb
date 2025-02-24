import 'package:hive/hive.dart';

part 'user_info.g.dart';

@HiveType(typeId: 0)
class UserInfo extends HiveObject {
  @HiveField(0)
  int id; // Add ID field

  @HiveField(1)
  String accountNo;

  @HiveField(2)
  int reward;

  @HiveField(3)
  String blovk;

  @HiveField(4)
  String dateTime;

  @HiveField(5)
  int isSynced;

  UserInfo({
    required this.id, // Include in constructor
    required this.accountNo,
    required this.reward,
    required this.blovk,
    required this.dateTime,
    required this.isSynced,
  });

  // Convert object to map
  Map<String, dynamic> toMap() {
    return {
      "id": id, // Include ID in the map
      "accountNo": accountNo,
      "reward": reward,
      "blovk": blovk,
      "dateTime": dateTime,
      "isSynced": isSynced,
    };
  }
}
