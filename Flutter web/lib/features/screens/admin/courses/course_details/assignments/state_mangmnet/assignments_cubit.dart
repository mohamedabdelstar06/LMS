import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'assignments_state.dart';

class AssignmentsCubit extends Cubit<AssignmentsState> {
  AssignmentsCubit() : super(AssignmentsInitial());
}
