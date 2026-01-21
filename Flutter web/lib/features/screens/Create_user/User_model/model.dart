class CreateUserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String nationalId;
  final DateTime dateOfBirth;
  final String gender;
  final String city;
  final String academicLevel;
  final String profileImageUrl;
  final bool isActive;
  final bool emailConfirmed;
  final DateTime createdAt;
  final DateTime updatedAt;
  // final DateTime? lastLoginAt;

  CreateUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.nationalId,
    required this.dateOfBirth,
    required this.gender,
    required this.city,
    required this.academicLevel,
    required this.profileImageUrl,
    required this.isActive,
    required this.emailConfirmed,
    required this.createdAt,
    required this.updatedAt,
    // this.lastLoginAt,
  });

  factory CreateUserModel.fromJson(Map<String, dynamic> json) {
    return CreateUserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      nationalId: json['nationalId'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      city: json['city'],
      academicLevel: json['academicLevel'],
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'],
      emailConfirmed: json['emailConfirmed'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      // lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'nationalId': nationalId,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'city': city,
      'academicLevel': academicLevel,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'emailConfirmed': emailConfirmed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // 'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}
