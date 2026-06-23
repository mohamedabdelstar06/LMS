






import '../model/view.dart';

abstract class TeacherProfileState {}

class TeacherProfileInitial extends TeacherProfileState {}

class TeacherProfileLoading extends TeacherProfileState {}

class TeacherProfileLoaded extends TeacherProfileState {
  TeacherProfileLoaded({required this.profile});
  final TeacherProfileUser profile;
}

class TeacherProfileError extends TeacherProfileState {
  TeacherProfileError({required this.message});
  final String message;
}

class TeacherProfileUpdating extends TeacherProfileState {}

class TeacherProfileUpdated extends TeacherProfileState {
  TeacherProfileUpdated({required this.profile});
  final TeacherProfileUser profile;
}
