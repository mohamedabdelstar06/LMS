import '../get_user_model/view.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<GetUserModel> users;
  final int pageIndex;
  final int totalPages;

  UsersLoaded({
    required this.users,
    required this.pageIndex,
    required this.totalPages,
  });
}

class UsersUnauthorized extends UsersState {}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}
