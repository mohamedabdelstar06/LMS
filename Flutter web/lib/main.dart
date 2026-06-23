import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/cons/context/navigation_key.dart';
import 'package:lms/core/services/app_initialization_service.dart';
import 'package:lms/features/widgets/chat_fab.dart'; // your existing ChatFab
import 'features/screens/auth/Verify_email/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 if (kDebugMode && kIsWeb) {
    FlutterError.onError = (details) {
      final msg = details.toString();
      if (msg.contains('toJsonMap') ||
          msg.contains('_nodeToJson') ||
          msg.contains('_handledContextLostEvent') ||
          msg.contains('LateInitializationError') ||
          msg.contains('onContextLost')) {
        return; // Flutter web engine bug — not our code
      }
      FlutterError.presentError(details);
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
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
        // ✅ This builder injects a global overlay above ALL navigated screens
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              ValueListenableBuilder<bool>(
                valueListenable: ChatFabController.visible,
                builder: (context, visible, _) {
                  if (!visible) return const SizedBox.shrink();
                  return const ChatFab();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
class ChatFabController {
  ChatFabController._();

  static final ValueNotifier<bool> _visible = ValueNotifier(false);
  static ValueNotifier<bool> get visible => _visible;

  static void show() => _visible.value = true;
  static void hide() => _visible.value = false;
}
