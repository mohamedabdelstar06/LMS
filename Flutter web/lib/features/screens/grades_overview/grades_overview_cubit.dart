import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/cons/api_helper_resources/api_resources.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';

import 'course_grades_model.dart';
import 'grades_overview_states.dart';

class CourseOption {
  const CourseOption({
    required this.id,
    required this.title,
    this.enrolledStudentsCount,
    this.instructorName,
  });

  final int id;
  final String title;
  final int? enrolledStudentsCount;
  final String? instructorName;
}

class GradesOverviewCubit extends Cubit<GradesOverviewState> {
  GradesOverviewCubit({this.isStudent = false}) : super(GradesOverviewInitial());

  final bool isStudent;
  final Dio _dio = Dio();

  List<CourseOption> _courses = [];
  CourseOption? _selectedCourse;
  CourseGradesOverviewModel? _grades;

  List<CourseOption> get courses => _courses;
  CourseOption? get selectedCourse => _selectedCourse;
  CourseGradesOverviewModel? get grades => _grades;

  Future<void> loadCourses() async {
    emit(GradesOverviewLoading());
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(GradesOverviewError('You are not authorized. Token missing.'));
        return;
      }

      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      late final List<dynamic> data;
      if (isStudent) {
        final response = await _dio.get(
          '${ApiResources.apiUrl}${ApiResources.getCourseStudentEndPoint}',
          options: options,
        );
        data = response.data as List<dynamic>;
      } else {
        final response = await _dio.get(
          '${ApiResources.apiUrl}${ApiResources.getCourseEndPoint}',
          options: options,
        );
        data = response.data as List<dynamic>;
      }

      _courses = data.map((e) {
        final json = e as Map<String, dynamic>;
        if (isStudent) {
          return CourseOption(
            id: json['courseId'] ?? 0,
            title: json['courseTitle'] ?? '',
            enrolledStudentsCount: json['enrolledStudentsCount'],
            instructorName: json['instructorName'],
          );
        }
        return CourseOption(
          id: json['id'] ?? 0,
          title: json['title'] ?? '',
          enrolledStudentsCount: json['enrolledStudentsCount'],
          instructorName: json['instructorName'],
        );
      }).toList();

      if (_courses.isEmpty) {
        emit(GradesOverviewCoursesLoaded(const []));
        return;
      }

      emit(GradesOverviewCoursesLoaded(_courses));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(GradesOverviewError('Unauthorized. Please login again.'));
      } else {
        emit(GradesOverviewError(e.message ?? 'Failed to load courses'));
      }
    } catch (e) {
      emit(GradesOverviewError(e.toString()));
    }
  }

  Future<void> selectCourse(CourseOption course) async {
    _selectedCourse = course;
    emit(GradesOverviewLoading());
    await _loadGrades(course.id);
  }

  Future<void> _loadGrades(int courseId) async {
    try {
      final token = await TokenStorageHelper.getTokenSecure();
      if (token == null || token.isEmpty) {
        emit(GradesOverviewError('You are not authorized. Token missing.'));
        return;
      }

      final response = await _dio.get(
        '${ApiResources.apiUrl}${ApiResources.courseGradesEndPoint.replaceFirst('{courseId}', courseId.toString())}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        _grades = CourseGradesOverviewModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        emit(GradesOverviewGradesLoaded(
          courses: _courses,
          selectedCourse: _selectedCourse!,
          grades: _grades!,
        ));
      } else if (response.statusCode == 401) {
        emit(GradesOverviewError('Unauthorized. Please login again.'));
      } else {
        emit(GradesOverviewError('Failed to load grades'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(GradesOverviewError('Unauthorized. Please login again.'));
      } else if (e.response?.statusCode == 403) {
        emit(GradesOverviewError('You do not have permission to view these grades.'));
      } else {
        emit(GradesOverviewError(e.message ?? 'Failed to load grades'));
      }
    } catch (e) {
      emit(GradesOverviewError(e.toString()));
    }
  }

  void refreshSelectedCourse() {
    if (_selectedCourse != null) {
      selectCourse(_selectedCourse!);
    }
  }
}
