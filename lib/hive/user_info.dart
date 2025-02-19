import 'package:hive/hive.dart';

part 'user_info.g.dart';

@HiveType(typeId: 0)
class UserInfo extends HiveObject {
  UserInfo({
    this.id,
    this.account_no,
    this.reward,
    this.generated_code,
    this.date_time,
  });

  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? account_no;

  @HiveField(2)
  final String? reward;

  @HiveField(3)
  final String? generated_code;

  @HiveField(4)
  final DateTime? date_time;

  // Convert UserInfo object to Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "account_no": account_no,
      "reward": reward,
      "generated_code": generated_code,
      "date_time": date_time?.toIso8601String(),
    };
  }

  // Create a UserInfo object from a Map<String, dynamic>
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json["id"],
      account_no: json["account_no"],
      reward: json["reward"],
      generated_code: json["generated_code"],
      date_time:
          json["date_time"] != null ? DateTime.parse(json["date_time"]) : null,
    );
  }
}
