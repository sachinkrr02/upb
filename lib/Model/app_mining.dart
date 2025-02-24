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
      accountNo: json['accountNo'],
      reward: json['reward'],
      generatedCode: json['blovk'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }

  // Convert from AppMining object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNo': accountNo,
      'reward': reward,
      'blovk': generatedCode,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AppMining(id: $id, accountNo: $accountNo, reward: $reward, generatedCode: $generatedCode, dateTime: $dateTime)';
  }
}
