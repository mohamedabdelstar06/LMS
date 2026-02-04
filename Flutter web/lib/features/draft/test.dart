import 'dart:ui_web' as ui;
import 'dart:html' as html;


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/draft/test_cubit.dart';
import 'package:lms/features/draft/test_models.dart';
import 'package:lms/features/draft/test_states.dart';

import '../screens/courses/course_model/courses.dart';

class CourseGridScreen extends StatelessWidget {
  const CourseGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetCourseCubit()..getCourses(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Courses'),
        ),
        body: BlocBuilder<GetCourseCubit, GetCourseState>(
          builder: (context, state) {
            if (state is GetCourseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GetCourseError) {
              return Center(child: Text(state.message));
            }

            if (state is GetCourseSuccess) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: state.courses.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final course = state.courses[index];
                    return CourseGridItem(course: course);
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
class CourseGridItem extends StatelessWidget {
  final GetCourseModel course;

  const CourseGridItem({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                ? WebImage(
              url: buildImageUrl(course.imageUrl),
              width: double.infinity,
              height: 120,
            )
                : const SizedBox(
              height: 120,
              child: Center(
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),

                /// Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: navigate or enroll
                    },
                    child: const Text('View Course'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return 'https://skylearn.runasp.net$imagePath';
  }

}

class WebImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const WebImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final viewId = url;

    ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final img = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      return img;
    });

    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewId),
    );
  }
}


