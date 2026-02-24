

import '../model/model.dart';

abstract class CoursesStateDrop {}

class CourseInitialState extends CoursesStateDrop {}

class CourseLoadingState extends CoursesStateDrop {}

class CourseLoadedState extends CoursesStateDrop {
  CourseLoadedState(this.courses);
  final List<GetCourseModel> courses;
}

class CoursesErrorState extends CoursesStateDrop {
  CoursesErrorState(this.message);
  final String message;
}


