
import '../ProfileModel/view.dart';

abstract class StudentProfileState {}

class StudentProfileInitial extends StudentProfileState {}

class StudentProfileLoading extends StudentProfileState {}

class StudentProfileLoaded extends StudentProfileState {
  StudentProfileLoaded({required this.profile});
  final StudentProfileModel profile;
}

class StudentProfileError extends StudentProfileState {
  StudentProfileError({required this.message});
  final String message;
}
class StudentProfileUpdating extends StudentProfileState {}

class StudentProfileUpdated extends StudentProfileState {
  StudentProfileUpdated({required this.profile});
  final StudentProfileModel profile;
}
