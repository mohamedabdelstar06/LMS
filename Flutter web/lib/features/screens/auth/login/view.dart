import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/auth/login/state_management/login_server_cubit.dart';
import 'package:lms/features/screens/auth/login/state_management/login_state.dart';

import '../../../../core/cons/Colors/app_colors.dart';
import '../../../../core/helpers/cach_helper/shared_pref_helper.dart';
import '../../../../generated/assets.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPressed = false;
  bool isObscure = true;
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController(

  );
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  Future<void> _loadSavedEmail() async {
    final savedEmail = await VerifyStorageHelper.getSavedEmail();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        usernameController.text = savedEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Builder(
        builder: (context) {
          final loginCubit = BlocProvider.of<LoginCubit>(context);
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MYColors.gradientColor_3,
                  MYColors.gradientColor_2.withValues(alpha: 0.25),
                  MYColors.gradientColor_3,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,

              body: Center(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: const Color(0xFF175cd3).withValues(alpha: 0.86),
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'inter',
                            ),
                          ),
                          const SizedBox(width: 5),
                          Image.asset(Assets.iconsHand),
                        ],
                      ),
                      const Text(
                        'Enter your details below to access your courses and progress.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'inter',
                          color: Color(0xFF545F70),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 17,
                        ),

                        width: 514,
                        height: 310,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'inter',
                                color: Color(0xFF175CD3),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'inter',
                                color: Colors.black87.withValues(alpha: 0.6),
                              ),
                              readOnly: true,
                              enabled: false,
                              controller: usernameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),

                              ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'inter',
                                color: Color(0xFF175CD3),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: passwordController,
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPressed = !isPressed;
                                      isObscure = !isObscure;
                                    });
                                  },
                                  icon: Icon(
                                    isPressed == true
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 17,
                                    color: const Color(0xFF99A1AF),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                hintText: 'Enter your password',

                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'inter',
                                  color: Color(0xFF08303D),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            BlocBuilder<LoginCubit, LoginState>(
                              bloc: loginCubit,
                              builder: (context, state) {
                                final isLoading = state is LoadingLoginState;

                                return InkWell(
                                  onTap: isLoading
                                      ? null
                                      : () {

                                          context
                                              .read<LoginCubit>()
                                              .postLoginData(
                                                usernameController,
                                                passwordController,
                                                context,
                                              );
                                        },
                                  child: Center(
                                    child: Container(
                                      width: 470,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF1849A9),
                                            Color(0xFF53B1FD),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Logging in...',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'inter',
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'inter',
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
