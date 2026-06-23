import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/helpers/cach_helper/shared_pref_helper.dart';
import 'package:lms/features/screens/chat_bot/state_managments/chat_cubit.dart';
import 'package:lms/features/screens/chat_bot/view.dart';

class ChatFab extends StatefulWidget {
  const ChatFab({super.key});

  @override
  State<ChatFab> createState() => _ChatFabState();
}

class _ChatFabState extends State<ChatFab> with SingleTickerProviderStateMixin {
  bool _isChatOpen = false;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final status = await PrefHelper.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = status;
      });
    }
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
    if (_isChatOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        if (_isChatOpen)
          GestureDetector(
            onTap: _toggleChat,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        if (_isChatOpen)
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: BlocProvider(
                      create: (context) => ChatCubit()..loadChatHistory(),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                            ),
                            child: Row(
                              children: [
                                const Image(
                                  image: AssetImage('assets/images/chatbot image.png'),
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'LearnMate',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _toggleChat,
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: LearnMateChat(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _toggleChat,
            backgroundColor: Colors.blue.shade600,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/images/chatbot image.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatFabWrapper extends StatelessWidget {
  final Widget child;

  const ChatFabWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const ChatFab(),
      ],
    );
  }
}
