import 'package:flutter/material.dart';
import 'package:lms/core/cons/context/navigation_key.dart';
import 'package:lms/features/screens/hero_section/view.dart';
import 'package:lms/features/screens/login/view.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.delayed(const Duration(seconds: 2));
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
        navigatorKey: navigatorKey,
        title: "SKY Learn",
        theme: ThemeData(useMaterial3: true,
          
        ),
        debugShowCheckedModeBanner: false,
        home: SizedBox(
          height: 1500,
          child:
          // LoginScreen()
          // CourseScreen()
          HeroSectionScreen()
          ),
        )


    );
  }
}

