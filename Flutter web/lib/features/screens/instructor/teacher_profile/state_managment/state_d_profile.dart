






import '../model/view.dart';

abstract class TeacherProfileState {}

class TeacherProfileInitial extends TeacherProfileState {}

class TeacherProfileLoading extends TeacherProfileState {}

class TeacherProfileLoaded extends TeacherProfileState {
  final TeacherProfileUser profile;
  TeacherProfileLoaded({required this.profile});
}

class TeacherProfileError extends TeacherProfileState {
  final String message;
  TeacherProfileError({required this.message});
}

class TeacherProfileUpdating extends TeacherProfileState {}

class TeacherProfileUpdated extends TeacherProfileState {
  final TeacherProfileUser profile;
  TeacherProfileUpdated({required this.profile});
}
