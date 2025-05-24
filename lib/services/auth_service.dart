import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      // 불필요한 접두사 제거
      String token = response.body.trim();
      if (token.startsWith('JWT 토큰:')) {
        token = token.replaceFirst('JWT 토큰:', '').trim();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return null;
    } else {
      return '로그인에 실패했습니다.';
    }
  }

  static Future<String?> register({
    required String username,
    required String name,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'name': name,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return jsonDecode(response.body)['message'] ?? '회원가입에 실패했습니다.';
    }
  }

  static Future<bool> isUsernameAvailable(String username) async {
    final url = Uri.parse('$baseUrl/api/auth/check-username');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    return response.statusCode == 200;
  }

  // 유저 정보 가져옴
  static Future<String?> fetchName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/user/info'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['name'];
    } else {
      return null;
    }
  }

  static Future<String?> fetchID() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/user/info'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['username'];
    } else {
      return null;
    }
  }

  static Future<String?> updateName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final response = await http.put(
      Uri.parse('$baseUrl/api/user/update-name'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': newName}),
    );

    if (response.statusCode == 200) {
      return "success"; // 성공
    } else {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['message'] ?? '닉네임 수정 실패';
    }
  }
}
