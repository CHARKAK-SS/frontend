import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 검정 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black,
              child: const Center(
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'PretendardBold',
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // 프로필 이미지
                      const Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black12,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 아이디 + 중복확인
                      const Text(
                        '    아이디',
                        style: TextStyle(
                          fontFamily: 'PretendardBold',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _idController,
                              hint: '아이디를 입력하세요',
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: 중복확인 로직
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              '중복확인',
                              style: TextStyle(
                                color: Colors.white, // 글자 색 흰색
                                fontFamily: 'PretendardRegular',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 이름
                      const Text(
                        '    이름',
                        style: TextStyle(
                          fontFamily: 'PretendardBold',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint: '이름을 입력하세요',
                      ),
                      const SizedBox(height: 20),

                      // 비밀번호
                      const Text(
                        '    비밀번호',
                        style: TextStyle(
                          fontFamily: 'PretendardBold',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _pwController,
                        hint: '비밀번호를 입력하세요',
                        obscure: true,
                      ),
                      const SizedBox(height: 20),

                      // 비밀번호 확인
                      const Text(
                        '    비밀번호 확인',
                        style: TextStyle(
                          fontFamily: 'PretendardBold',
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _pwConfirmController,
                        hint: '비밀번호를 다시 입력하세요',
                        obscure: true,
                      ),
                      const SizedBox(height: 40),

                      // 회원가입 버튼
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: 회원가입 처리 로직
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontFamily: 'PretendardBold',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'PretendardRegular',
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
    );
  }
}
