// abstract class CreateState {}
//
// class CreateUserInitialState extends CreateState {}
//
// class LoadingCreateUserState extends CreateState {}
//
// class CreateUserSuccessState extends CreateState {}
//
// class CreateUserErrorState extends CreateState {}
abstract class CreateState {}

class CreateUserInitialState extends CreateState {}

class LoadingCreateUserState extends CreateState {}

class CreateUserSuccessState extends CreateState {
  final int? statusCode;
  final String? message;

  CreateUserSuccessState({this.statusCode, this.message});
}

class CreateUserErrorState extends CreateState {
  final String errorMessage;
  final int? statusCode;

  CreateUserErrorState(this.errorMessage, {this.statusCode});
}