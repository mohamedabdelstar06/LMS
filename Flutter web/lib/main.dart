import 'package:flutter/material.dart';
import 'package:lms/features/screens/login/view.dart';

import 'features/screens/courses/view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: MaterialApp(
        title: "SKY Learn",
        theme: ThemeData(useMaterial3: true,
          
        ),
        debugShowCheckedModeBanner: false,
        home: SizedBox(
          height: 1500,
          child: PageView(
            children: [
              // LoginScreen(),
              CourseScreen(),
            ],
          ),
        )

      ),
    );
  }
}

