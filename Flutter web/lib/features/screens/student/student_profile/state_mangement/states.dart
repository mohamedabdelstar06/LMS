
import '../ProfileModel/view.dart';

abstract class StudentProfileState {}

class StudentProfileInitial extends StudentProfileState {}

class StudentProfileLoading extends StudentProfileState {}

class StudentProfileLoaded extends StudentProfileState {
  final StudentProfileModel profile;
  StudentProfileLoaded({required this.profile});
}

class StudentProfileError extends StudentProfileState {
  final String message;
  StudentProfileError({required this.message});
}
class StudentProfileUpdating extends StudentProfileState {}

class StudentProfileUpdated extends StudentProfileState {
  final StudentProfileModel profile;
  StudentProfileUpdated({required this.profile});
}
