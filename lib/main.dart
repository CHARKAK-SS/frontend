import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Spot', // 앱의 제목
      theme: ThemeData(
        primarySwatch: Colors.blue, // 앱의 기본 테마 색상
      ),
      home: const LoginScreen(), // 앱이 실행될 때 첫 화면
    );
  }
}
