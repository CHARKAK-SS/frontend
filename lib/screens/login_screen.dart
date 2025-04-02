import 'package:flutter/material.dart';
import 'mainpage_screen.dart'; // MainPageScreen 추가

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    // 로그인 검증 (임시로 성공 처리)
    final id = _idController.text;
    final pw = _passwordController.text;

    if (id.isNotEmpty && pw.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPageScreen()), // 로그인 후 이동
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디와 비밀번호를 입력하세요')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/camera.png', width: 100, height: 100),
              const SizedBox(height: 50),

              // 아이디 입력
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: '아이디를 입력하세요',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력하세요',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 로그인 버튼
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ), // 내부 여백 조정
                  minimumSize: const Size(
                    150,
                    50,
                  ), // 버튼 최소 크기 설정 (너비 200, 높이 50)
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'PretendardBold',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 회원가입 텍스트
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // 회원가입 페이지로 이동
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text(
                    '회원가입 >',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'PretendardBold',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
