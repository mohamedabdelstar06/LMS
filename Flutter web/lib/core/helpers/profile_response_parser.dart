import 'package:lms/features/screens/admin/admin_profile/model/view.dart';
import 'package:lms/features/screens/instructor/teacher_profile/model/view.dart'
    as teacher;

AdminProfileUser parseAdminProfileResponse(dynamic data) {
  if (data is! Map) {
    throw const FormatException('Invalid profile response');
  }

  final map = Map<String, dynamic>.from(data);
  if (map.containsKey('user')) {
    return AdminProfileUser.fromJson(map);
  }

  return AdminProfileUser(
    message: map['message']?.toString() ?? '',
    success: map['success'] as bool? ?? true,
    user: User.fromJson(map),
  );
}

teacher.TeacherProfileUser parseTeacherProfileResponse(dynamic data) {
  if (data is! Map) {
    throw const FormatException('Invalid profile response');
  }

  final map = Map<String, dynamic>.from(data);
  if (map.containsKey('user')) {
    return teacher.TeacherProfileUser.fromJson(map);
  }

  return teacher.TeacherProfileUser(
    message: map['message']?.toString() ?? '',
    success: map['success'] as bool? ?? true,
    user: teacher.User.fromJson(map),
  );
}
