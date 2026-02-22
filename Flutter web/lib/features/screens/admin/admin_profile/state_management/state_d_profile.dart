






import '../model/view.dart';

abstract class AdminProfileState {}

class AdminProfileInitial extends AdminProfileState {}

class AdminProfileLoading extends AdminProfileState {}

class AdminProfileLoaded extends AdminProfileState {
  AdminProfileLoaded({required this.profile});
  final AdminProfileUser profile;
}

class AdminProfileError extends AdminProfileState {
  AdminProfileError({required this.message});
  final String message;
}


class AdminProfileUpdating extends AdminProfileState {}

class AdminProfileUpdated extends AdminProfileState {
  AdminProfileUpdated({required this.profile});
  final AdminProfileUser profile;
}
