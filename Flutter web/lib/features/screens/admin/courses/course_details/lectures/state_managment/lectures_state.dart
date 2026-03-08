abstract class LectureState {
  const LectureState();
}

class LectureInitial extends LectureState {
  const LectureInitial();
}

class LectureLoading extends LectureState {
  const LectureLoading();
}

class LectureLoaded extends LectureState {
  const LectureLoaded(this.lectures);
  final List<dynamic> lectures;
}

class LectureError extends LectureState {
  const LectureError(this.message);
  final String message;
}

class LectureCreateLoading extends LectureState {
  const LectureCreateLoading({this.progress = 0.0});
  final double progress;
}

class LectureCreateSuccess extends LectureState {
  const LectureCreateSuccess();
}

class LectureCreateError extends LectureState {
  const LectureCreateError(this.message);
  final String message;
}

class LectureUpdateLoading extends LectureState {
  const LectureUpdateLoading({this.progress = 0.0});
  final double progress;
}

class LectureUpdateSuccess extends LectureState {
  const LectureUpdateSuccess();
}

class LectureUpdateError extends LectureState {
  const LectureUpdateError(this.message);
  final String message;
}

class LectureDeleteLoading extends LectureState {
  const LectureDeleteLoading();
}

class LectureDeleteSuccess extends LectureState {
  const LectureDeleteSuccess(this.message);
  final String message;
}

class LectureDeleteError extends LectureState {
  const LectureDeleteError(this.message);
  final String message;
}