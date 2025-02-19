class LoginResponse {
  final int userId;
  final String name;
  final String uniqueId;
  final String method;
  final String message;
  final String errorCode;

  LoginResponse({
    required this.userId,
    required this.name,
    required this.uniqueId,
    required this.method,
    required this.message,
    required this.errorCode,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'],
      name: json['name'],
      uniqueId: json['uniqueId'],
      method: json['method'],
      message: json['message'],
      errorCode: json['errorCode'],
    );
  }
}
