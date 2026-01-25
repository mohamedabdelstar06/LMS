class ProfileUserData {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? nationalId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? city;
  final String? profileImageUrl;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final dynamic academicInfo;

  ProfileUserData({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.nationalId,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.profileImageUrl,
    required this.accountStatus,
    required this.createdAt,
    required this.lastLoginAt,
    this.academicInfo,
  });

  factory ProfileUserData.fromJson(Map<String, dynamic> json) {
    return ProfileUserData(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      nationalId: json['nationalId'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      city: json['city'],
      profileImageUrl: json['profileImageUrl'],
      accountStatus: json['accountStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      academicInfo: json['academicInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'nationalId': nationalId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'city': city,
      'profileImageUrl': profileImageUrl,
      'accountStatus': accountStatus,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'academicInfo': academicInfo,
    };
  }
}
