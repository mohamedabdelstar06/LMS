import 'package:flutter/material.dart';
import 'package:lms/features/screens/others/tapbar/activites/view.dart';
import 'package:lms/features/screens/others/tapbar/course_tapbar_View/view.dart';
import 'package:lms/features/screens/others/tapbar/grades/view.dart';
import 'package:lms/features/screens/others/tapbar/participants/view.dart';

import '../../../core/widgets/app_bar.dart';




class CelebratingScreen extends StatelessWidget {
  const CelebratingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white70,
        ),

        child: ListView(
          padding: const EdgeInsetsDirectional.only(start: 70, top: 15,end: 70),
          children: const [
            SizedBox(height: 20),

            Text(
              'Celebrating Cultures',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 25),

            DefaultTabController(
              length: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  TabBar(
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Course'),
                      Tab(text: 'Participants'),
                      Tab(text: 'Grades'),
                      Tab(text: 'Activities'),
                    ],
                  ),

                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      children: [
                        CourseTapbarScreen(),
                        ParticipantsTapbarScreen(),
                        GradesTapbarScreen(),
                        ActivitesTapbarScreen(),
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
