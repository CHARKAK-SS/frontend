import 'package:flutter/material.dart';
import 'package:charkak/services/auth_service.dart';
import 'mainpage_screen.dart';
import 'register_screen.dart'; // ✅ 회원가입 화면 import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _handleLogin() async {
    final id = _idController.text;
    final pw = _passwordController.text;

    if (id.isEmpty || pw.isEmpty) {
      _showMessage('아이디와 비밀번호를 입력하세요');
      return;
    }

    final error = await AuthService.login(username: id, password: pw);

    if (error == null) {
      _showMessage('로그인 성공!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPageScreen()),
      );
    } else {
      _showMessage(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/camera.png', width: 100, height: 100),
              const SizedBox(height: 50),

              TextField(
                controller: _idController,
                decoration: _inputDecoration('아이디를 입력하세요'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration('비밀번호를 입력하세요'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                style: _buttonStyle(),
                child: const Text('로그인', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 30),

              // ✅ 회원가입 텍스트
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      minimumSize: const Size(150, 50),
    );
  }
}
