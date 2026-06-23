class UserStatusModel {

  UserStatusModel({
    this.email,
    required this.exists,
    required this.isActivated,
  });

  factory UserStatusModel.fromJson(Map<String, dynamic> json) {
    return UserStatusModel(
      email: json['email'],
      exists: json['exists'] ?? false,
      isActivated: json['isActivated'] ?? false,
    );
  }
  final String? email;
  final bool exists;
  final bool isActivated;
}