import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'student_activities_state.dart';

class StudentActivitiesCubit extends Cubit<StudentActivitiesState> {
  StudentActivitiesCubit() : super(StudentActivitiesInitial());
}
