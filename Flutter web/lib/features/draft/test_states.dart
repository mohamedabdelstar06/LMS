

import 'package:lms/features/draft/test_models.dart';

abstract class ImportStudentsState {}

class ImportStudentsInitial extends ImportStudentsState {}

class ImportStudentsLoading extends ImportStudentsState {}

class ImportStudentsSuccess extends ImportStudentsState {
  final ImportStudentsResponseModel response;

  ImportStudentsSuccess(this.response);
}

class ImportStudentsError extends ImportStudentsState {
  final String message;

  ImportStudentsError(this.message);
}