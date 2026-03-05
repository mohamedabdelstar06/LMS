import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/cons/context/navigation_key.dart';
import 'package:lms/core/services/app_initialization_service.dart';
import 'package:lms/features/screens/pre_processing/pre_loading/loading_screen.dart';
import 'features/screens/admin/courses/course_details/comments/functions/comment_time.dart';
import 'features/screens/auth/Verify_email/view.dart';






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode && kIsWeb) {
    FlutterError.onError = (details) {
      if (!details.toString().contains('toJsonMap') &&
          !details.toString().contains('_nodeToJson')) {
        FlutterError.presentError(details);
      }
    };
  }



  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    await AppInitializationService.initializeApp();
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        scrollBehavior:  const ScrollBehavior().copyWith(scrollbars: false),

        navigatorKey: navigatorKey,
        title: 'SKY Learn',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'inter',
          scaffoldBackgroundColor: const Color(0xFFE0F2FE),
        ),
        debugShowCheckedModeBanner: false,
        home:

        _isInitialized ? const VerifyScreen() : const LoadingScreen(),
      ),
    );
  }
}

