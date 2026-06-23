


import '../model/model.dart';

abstract class ImportStudentsState {}

class ImportStudentsInitial extends ImportStudentsState {}

class ImportStudentsLoading extends ImportStudentsState {}

class ImportStudentsSuccess extends ImportStudentsState {

  ImportStudentsSuccess(this.response);
  final ImportStudentsResponseModel response;
}

class ImportStudentsError extends ImportStudentsState {

  ImportStudentsError(this.message);
  final String message;
}