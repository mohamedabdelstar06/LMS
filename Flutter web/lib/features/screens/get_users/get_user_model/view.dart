

// class UsersResponseModel {
//   final List<GetUserModel> users;
//   final int totalCount;
//   final int pageNumber;
//   final int pageSize;
//   final int totalPages;
//   final bool hasNextPage;
//   final bool hasPreviousPage;
//
//   UsersResponseModel({
//     required this.users,
//     required this.totalCount,
//     required this.pageNumber,
//     required this.pageSize,
//     required this.totalPages,
//     required this.hasNextPage,
//     required this.hasPreviousPage,
//   });
//
//   factory UsersResponseModel.fromJson(Map<String, dynamic> json) {
//     return UsersResponseModel(
//       users: (json['users'] as List<dynamic>)
//           .map((e) => GetUserModel.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       totalCount: json['totalCount'] as int,
//       pageNumber: json['pageNumber'] as int,
//       pageSize: json['pageSize'] as int,
//       totalPages: json['totalPages'] as int,
//       hasNextPage: json['hasNextPage'] as bool,
//       hasPreviousPage: json['hasPreviousPage'] as bool,
//     );
//   }
// }
class UsersResponseModel {
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final List<GetUserModel> users;

  UsersResponseModel({
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.users,
  });

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) {
    return UsersResponseModel(
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      users: List<GetUserModel>.from(
        (json['users'] ?? []).map((e) => GetUserModel.fromJson(e)),
      ),
    );
  }
}





class GetUserModel {
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
    required this.nationalId,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.profileImageUrl,
    required this.accountStatus,
    required this.emailConfirmed,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.academicInfo,
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) {
    return GetUserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      nationalId: json['nationalId'] as String,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      accountStatus: json['accountStatus'] as String,
      emailConfirmed: json['emailConfirmed'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      academicInfo: (json['academicInfo'] != null &&
          json['academicInfo'] is Map<String, dynamic>)
          ? AcademicInfoModel.fromJson(json['academicInfo'])
          : null, // ✅ هنا صار nullable
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
      squadron: json['squadron'] != null
          ? SimpleItemModel.fromJson(json['squadron'])
          : null,
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
