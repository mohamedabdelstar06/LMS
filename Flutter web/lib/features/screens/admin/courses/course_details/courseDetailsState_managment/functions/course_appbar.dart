import 'package:flutter/material.dart';
import 'package:lms/core/helpers/api_url_helper.dart';
import '../../../home_courses/model/model.dart';
import 'department_chip.dart';

class CourseHeroAppBar extends StatelessWidget {
  const CourseHeroAppBar({required this.course, super.key});
  final GetCoursesModel course;

  String _buildImageUrl(String imageUrl) {
    return ApiUrlHelper.resolveMediaUrl(imageUrl) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 290,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0369A1),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0C4A6E), Color(0xFF0369A1), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            const Positioned(top: 18, left: 55, child: _StarDot(size: 3)),
            const Positioned(top: 35, left: 120, child: _StarDot(size: 2)),
            const Positioned(top: 12, right: 80, child: _StarDot(size: 2.5)),
            const Positioned(top: 55, right: 140, child: _StarDot(size: 2)),
            const Positioned(top: 28, left: 200, child: _StarDot(size: 3)),
            const Positioned(top: 70, left: 30, child: _StarDot(size: 2)),
            const Positioned(top: 10, right: 55, child: _StarDot(size: 3)),
            const Positioned(top: 20, right: 55, child: _StarDot(size: 3)),
            const Positioned(top: 40, left: 55, child: _StarDot(size: 3)),
            const Positioned(top: 100, right: 55, child: _StarDot(size: 3)),
            const Positioned(top: 150, left: 55, child: _StarDot(size: 3)),
            const Positioned(top: 120, left: 55, child: _StarDot(size: 3)),

            const Positioned(
              top: -40,
              left: -40,
              child: _RingDecor(size: 140, opacity: 0.08),
            ),
            const Positioned(
              bottom: 60,
              right: -50,
              child: _RingDecor(size: 160, opacity: 0.07),
            ),
            const Positioned(
              top: 20,
              right: -20,
              child: _RingDecor(size: 80, opacity: 0.1),
            ),

            Positioned(
              top: 22,
              right: 22,
              child: Transform.rotate(
                angle: 0.3,
                child: const Icon(Icons.airplanemode_active, color: Colors.white60, size: 36),
              ),
            ),
            Positioned(
              top: 110,
              left: 16,
              child: Transform.rotate(
                angle: -0.4,
                child: const Icon(Icons.airplanemode_active, color: Colors.white38, size: 24),
              ),
            ),
            const Positioned(
              top: 30,
              left: 22,
              child: Icon(Icons.auto_stories, color: Colors.white30, size: 26),
            ),
            const Positioned(
              bottom: 155,
              right: 28,
              child: Icon(Icons.menu_book, color: Colors.white38, size: 28),
            ),
            const Positioned(
              bottom: 148,
              left: 28,
              child: Icon(Icons.school, color: Colors.white30, size: 26),
            ),
            const Positioned(
              top: 60,
              right: 70,
              child: Icon(Icons.lightbulb_outline, color: Colors.white24, size: 22),
            ),
            const Positioned(
              top: 75,
              left: 80,
              child: Icon(Icons.science_outlined, color: Colors.white24, size: 20),
            ),

            Center(
              child: Container(

                margin: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 36,
                  bottom: 90,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    _buildImageUrl(course.imageUrl),
                    width: 350,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 185,
                        color: Colors.white10,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_fallback.png',
                      height: 185,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 18,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DepartmentChip(label: course.departmentName),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarDot extends StatelessWidget {
  const _StarDot({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RingDecor extends StatelessWidget {
  const _RingDecor({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
