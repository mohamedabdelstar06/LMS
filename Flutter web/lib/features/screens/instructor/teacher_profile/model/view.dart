
import 'package:intl/intl.dart';
class TeacherProfileUser {

  TeacherProfileUser({
    required this.message,
    required this.success,
    required this.user,
  });

  factory TeacherProfileUser.fromJson(Map<String, dynamic> json) =>
      TeacherProfileUser(
        message: json['message'] ?? '',
        success: json['success'] ?? false,
        user: User.fromJson(json['user'] ?? {}),
      );
  final String message;
  final bool success;
  final User user;

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
    'user': user.toJson(),
  };
}

class User {

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.nationalId,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.profileImageUrl,
    required this.accountStatus,
    required this.createdAt,
    required this.lastLoginAt,
    required this.academicInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    }

    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? '',
      nationalId: json['nationalId'] ?? '',
      dateOfBirth: formatDate(json['dateOfBirth']),
      gender: json['gender'],
      city: json['city'],
      profileImageUrl: json['profileImageUrl'],
      accountStatus: json['accountStatus'] ?? '',
      createdAt: formatDate(json['createdAt']),
      lastLoginAt: formatDate(json['lastLoginAt']),
      academicInfo: AcademicInfo.fromJson(json['academicInfo'] ?? <String, dynamic>{}),
    );
  }
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String nationalId;
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? profileImageUrl;
  final String accountStatus;
  final String createdAt;
  final String lastLoginAt;
  final AcademicInfo academicInfo;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'role': role,
    'nationalId': nationalId,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'city': city,
    'profileImageUrl': profileImageUrl,
    'accountStatus': accountStatus,
    'createdAt': createdAt,
    'lastLoginAt': lastLoginAt,
    'academicInfo': academicInfo.toJson(),
  };
}

class AcademicInfo {

  AcademicInfo({
    required this.department,
    required this.year,
    required this.squadron,
    required this.admissionYear,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) => AcademicInfo(
    department: Department.fromJson(json['department'] ?? {}),
    year: Year.fromJson(json['year'] ?? {}),
    squadron: Squadron.fromJson(json['squadron'] ?? {}),
    admissionYear: json['admissionYear'] ?? 0,
  );
  final Department department;
  final Year year;
  final Squadron squadron;
  final int admissionYear;

  Map<String, dynamic> toJson() => {
    'department': department.toJson(),
    'year': year.toJson(),
    'squadron': squadron.toJson(),
    'admissionYear': admissionYear,
  };
}

class Department {

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
  );
  final int id;
  final String name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class Year {

  Year({required this.id, required this.name});

  factory Year.fromJson(Map<String, dynamic> json) => Year(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
  );
  final int id;
  final String name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class Squadron {

  Squadron({required this.id, required this.name});

  factory Squadron.fromJson(Map<String, dynamic> json) => Squadron(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
  );
  final int id;
  final String name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

