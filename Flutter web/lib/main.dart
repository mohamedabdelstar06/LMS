import 'package:flutter/material.dart';

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
        home: MyFirstFeature(),
      ),
    );
  }
}

class MyFirstFeature extends StatelessWidget {
  const MyFirstFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center());
  }
}
