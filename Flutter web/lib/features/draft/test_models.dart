<<<<<<< HEAD
class GetCourseModel {
  final int id;
  final String title;
  final String description;
  final int departmentId;
  final String departmentName;
  final int yearId;
  final String yearName;
  final int creditHours;
  final int enrolledStudentsCount;
  final String imageUrl;
  final int instructorId;
  final String instructorName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GetCourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.departmentId,
    required this.departmentName,
    required this.yearId,
    required this.yearName,
    required this.creditHours,
    required this.enrolledStudentsCount,
    required this.imageUrl,
    required this.instructorId,
    required this.instructorName,
    required this.createdAt,
    this.updatedAt,
  });

  factory GetCourseModel.fromJson(Map<String, dynamic> json) {
    return GetCourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      yearId: json['yearId'],
      yearName: json['yearName'],
      creditHours: json['creditHours'],
      enrolledStudentsCount: json['enrolledStudentsCount'],
      imageUrl: json['imageUrl'],
      instructorId: json['instructorId'],
      instructorName: json['instructorName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'yearId': yearId,
      'yearName': yearName,
      'creditHours': creditHours,
      'enrolledStudentsCount': enrolledStudentsCount,
      'imageUrl': imageUrl,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
=======
class UsersResponseModel {
  final List<GetUserModel> users;
  final int totalPages;
  final int pageNumber;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int totalCount;

  UsersResponseModel({
    required this.users,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.totalCount,
  });

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) {
    final usersJson = json['users'];

    return UsersResponseModel(
      users: usersJson is List
          ? usersJson.map((e) => GetUserModel.fromJson(e)).toList()
          : [],
      totalPages: json['totalPages'] ?? 1,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  UsersResponseModel copyWith({
    List<GetUserModel>? users,
    int? totalPages,
    int? pageNumber,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
    int? totalCount,
  }) {
    return UsersResponseModel(
      users: users ?? this.users,
      totalPages: totalPages ?? this.totalPages,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class GetUserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final String? nationalId;
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? profileImageUrl;
  final String accountStatus;
  final bool emailConfirmed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final AcademicInfoModel? academicInfo;

  GetUserModel({
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
    required this.emailConfirmed,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.academicInfo,
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) {
    return GetUserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      nationalId: json['nationalId'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      accountStatus: json['accountStatus'] as String,
      emailConfirmed: json['emailConfirmed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      academicInfo: json['academicInfo'] != null
          ? AcademicInfoModel.fromJson(json['academicInfo'])
          : null,
    );
  }
}

class AcademicInfoModel {
  final SimpleItemModel? department;
  final SimpleItemModel? year;
  final SimpleItemModel? squadron;
  final int? admissionYear;

  AcademicInfoModel({
    this.department,
    this.year,
    this.squadron,
    this.admissionYear,
  });

  factory AcademicInfoModel.fromJson(Map<String, dynamic> json) {
    return AcademicInfoModel(
      department: json['department'] != null
          ? SimpleItemModel.fromJson(json['department'])
          : null,
      year: json['year'] != null ? SimpleItemModel.fromJson(json['year']) : null,
      squadron: json['squadron'] != null ? SimpleItemModel.fromJson(json['squadron']) : null,
      admissionYear: json['admissionYear'] as int?,
    );
  }
}


class SimpleItemModel {
  final int id;
  final String name;

  SimpleItemModel({
    required this.id,
    required this.name,
  });

  factory SimpleItemModel.fromJson(Map<String, dynamic> json) {
    return SimpleItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
>>>>>>> a73edcf5f8df9effe9e6e7d241d527aad2b4a89b
