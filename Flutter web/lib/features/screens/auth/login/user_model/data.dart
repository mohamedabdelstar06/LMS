

import '../../../../../generated/assets.dart';

class UserModel {
  String message;
  String token;
  String expiresIn;
  User user;

  UserModel({
    required this.message,
    required this.token,
    required this.expiresIn,
    required this.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      expiresIn: json['expiresIn'] ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'expiresIn': expiresIn,
      'user': user.toJson(),
    };
  }
}

class User {
  int id;
  String fullName;
  String email;
  String role;
  String gender;
  String city;
  String profileImageUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.gender,
    required this.city,
    required this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? profileUrl = json['profileImageUrl'];

    return User(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      gender: json['gender'] ?? '',
      city: json['city'] ?? '',
      profileImageUrl: (profileUrl == null || profileUrl.isEmpty || profileUrl == 'null')
          ? Assets.logo
          : profileUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'gender': gender,
      'city': city,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.empty() {
    return User(
      id: 0,
      fullName: '',
      email: '',
      role: '',
      gender: '',
      city: '',
      profileImageUrl: '',
    );
  }
}
