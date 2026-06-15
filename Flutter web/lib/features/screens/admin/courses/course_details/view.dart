import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/loading_screen.dart';
import '../home_courses/model/model.dart';
import 'courseDetailsState_managment/course_details_cubit.dart';
import 'courseDetailsState_managment/course_details_state.dart';
import 'courseDetailsState_managment/functions/error_screen_function.dart';
import 'courseDetailsState_managment/functions/loaded_screen.dart';
import 'courseDetailsState_managment/functions/loadingScreen.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.courseModel});
  final GetCoursesModel courseModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CourseDetailsCubit()..loadCourseById( courseModel.id),
      child: const _CourseDetailsView(),
    );
  }
}

class _CourseDetailsView extends StatelessWidget {
  const _CourseDetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
      builder: (context, state) {
        if (state is CourseDetailsLoading || state is CourseDetailsInitial) {
          return const LoadingScreenDetails();
        }
        if (state is CourseDetailsError) {
          return ErrorScreen(message: state.message);
        }
        if (state is CourseDetailsLoaded) {
          return LoadedScreen(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

























