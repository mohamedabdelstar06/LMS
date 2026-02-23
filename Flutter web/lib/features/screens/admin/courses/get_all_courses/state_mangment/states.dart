

import '../model/model.dart';

abstract class CoursesStateDrop {}

class CourseInitialState extends CoursesStateDrop {}

class CourseLoadingState extends CoursesStateDrop {}

class CourseLoadedState extends CoursesStateDrop {
  final List<GetCourseModel> courses;
  CourseLoadedState(this.courses);
}

class CoursesErrorState extends CoursesStateDrop {
  final String message;
  CoursesErrorState(this.message);
}