//import 'package:charkak/screens/login_screen.dart';
import 'package:charkak/screens/mainpage_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'screens/spotdetail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null); // 날짜 로케일 초기화
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
      home: const MainPageScreen(), // 앱이 실행될 때 첫 화면
    );
  }
}
