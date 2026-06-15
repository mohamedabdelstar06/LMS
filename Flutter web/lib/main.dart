import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/cons/context/navigation_key.dart';
import 'package:lms/core/services/app_initialization_service.dart';
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

  await AppInitializationService.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        scrollBehavior: const ScrollBehavior().copyWith(scrollbars: false),
        navigatorKey: navigatorKey,
        title: 'SKY Learn',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'inter',
          scaffoldBackgroundColor: const Color(0xFFE0F2FE),
        ),
        debugShowCheckedModeBanner: false,
        home: const VerifyScreen(),
      ),
    );
  }
}
