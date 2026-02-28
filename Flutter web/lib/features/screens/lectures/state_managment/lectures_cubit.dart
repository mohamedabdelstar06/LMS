import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'lectures_state.dart';

class LecturesCubit extends Cubit<LecturesState> {
  LecturesCubit() : super(LecturesInitial());
}
