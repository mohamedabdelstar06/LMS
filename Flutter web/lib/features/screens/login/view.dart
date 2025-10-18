import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/Colors/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPressed = false;
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MYColors.gradientColor_3,
            MYColors.gradientColor_1.withValues(alpha: 0.35),
            MYColors.gradientColor_3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: "inter",
                    ),
                  ),
                  SizedBox(width: 5),
                  Image.asset("assets/icons/hand.png"),
                ],
              ),
              Text(
                "Enter your details below to access your courses and progress.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "inter",
                  color: Color(0xFF545F70),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),

                width: 514,
                height: 351,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Username",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: "inter",
                        color: Color(0xFF175CD3),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(

                        border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(12),

                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        hintText: "Enter your username",
                        hintStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: "inter",
                          color: Color(0xFF08303D),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: "inter",
                        color: Color(0xFF175CD3),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
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
                            color: Color(0xFF99A1AF),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        hintText: "Enter your password",

                        hintStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: "inter",
                          color: Color(0xFF08303D),
                        ),
                      ),
                    ),
                    SizedBox(height: 9),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Forget Password?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: "inter",
                              color: Color(0xff38BDF8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 13),

                    InkWell(
                      onTap: () {
                        SystemSound.play(SystemSoundType.click);
                      },
                      child: Center(
                        child: Container(
                          width: 470,
                          height: 45,

                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1849A9), Color(0xFF53B1FD)],
                            ),

                            color: Color(0xFF175CD3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: "inter",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
