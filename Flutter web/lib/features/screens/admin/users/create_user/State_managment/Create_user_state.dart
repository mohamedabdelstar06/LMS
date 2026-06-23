// abstract class CreateState {}
//
// class CreateUserInitialState extends CreateState {}
//
// class LoadingCreateUserState extends CreateState {}
//
// class CreateUserSuccessState extends CreateState {}
//
// class CreateUserErrorState extends CreateState {}
//************************
abstract class CreateState {}

class CreateUserInitialState extends CreateState {}

class LoadingCreateUserState extends CreateState {}

class CreateUserSuccessState extends CreateState {

  CreateUserSuccessState({this.statusCode, this.message});
  final int? statusCode;
  final String? message;
}

class CreateUserErrorState extends CreateState {

  CreateUserErrorState(this.errorMessage, {this.statusCode});
  final String errorMessage;
  final int? statusCode;
}

