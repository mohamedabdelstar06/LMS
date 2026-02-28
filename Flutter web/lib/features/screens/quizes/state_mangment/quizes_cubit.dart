import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'quizes_state.dart';

class QuizesCubit extends Cubit<QuizesState> {
  QuizesCubit() : super(QuizesInitial());
}
