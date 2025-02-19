import 'dart:convert';

class AppMining {
  final String id;
  final String accountNo;
  final String reward;
  final String generatedCode;
  final DateTime dateTime;

  AppMining({
    required this.id,
    required this.accountNo,
    required this.reward,
    required this.generatedCode,
    required this.dateTime,
  });

  // Convert from JSON (Map) to AppMining object
  factory AppMining.fromJson(Map<String, dynamic> json) {
    return AppMining(
      id: json['id'],
      accountNo: json['account_no'],
      reward: json['reward'],
      generatedCode: json['generated_code'],
      dateTime: DateTime.parse(json['date_time']),
    );
  }

  // Convert from AppMining object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'UserId': id,
      'account_no': accountNo,
      'reward': reward,
      'generated_code': generatedCode,
      'date_time': dateTime.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AppMining(id: $id, accountNo: $accountNo, reward: $reward, generatedCode: $generatedCode, dateTime: $dateTime)';
  }
}
