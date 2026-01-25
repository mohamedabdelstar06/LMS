import '../user_model/view.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class NavigateToTeacherProfile extends ProfileState {
  final ProfileUserData user;
  NavigateToTeacherProfile(this.user);
}

class NavigateToStudentProfile extends ProfileState {
  final ProfileUserData user;
  NavigateToStudentProfile(this.user);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
