class LoginUserModel {
  LoginUserModel({
    required this.userId,
    required this.email,
    required this.password,
    required this.sei,
    required this.mei,
    required this.kankaku,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      password: json['password'] as String,
      sei: json['sei'] as String,
      mei: json['mei'] as String,
      kankaku: json['kankaku'] as int,
    );
  }

  final int userId;
  final String email;
  final String password;
  final String sei;
  final String mei;
  final int kankaku; // 秒単位
}
