abstract class LectureState {}

class LectureInitial extends LectureState {}

class LectureLoading extends LectureState {}

class LectureLoaded extends LectureState {
  LectureLoaded(this.lectures);
  final List<dynamic> lectures;
}

class LectureError extends LectureState {
  LectureError(this.message);
  final String message;
}

class LectureCreateLoading extends LectureState {}

class LectureCreateSuccess extends LectureState {
  LectureCreateSuccess(this.message);
  final String message;
}

class LectureCreateError extends LectureState {
  LectureCreateError(this.message);
  final String message;
}

class LectureUpdateLoading extends LectureState {}

class LectureUpdateSuccess extends LectureState {
  LectureUpdateSuccess(this.message);
  final String message;
}

class LectureUpdateError extends LectureState {
  LectureUpdateError(this.message);
  final String message;
}

class LectureDeleteLoading extends LectureState {}

class LectureDeleteSuccess extends LectureState {
  LectureDeleteSuccess(this.message);
  final String message;
}

class LectureDeleteError extends LectureState {
  LectureDeleteError(this.message);
  final String message;
}