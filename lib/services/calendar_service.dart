import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CalendarService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // ✅ 이미지 업로드
  
  static Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return respStr.replaceAll('"', ''); // URL 문자열만 추출
    } else {
      return null;
    }
  }


  static Future<bool> saveCalendar({
    required String location,
    required String diaryText,
    required DateTime date,
    required String imageUrl,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/api/calendar/save');
    final response = await http.post(
      uri,
      headers: {
        //'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'location': location,
        'diaryText': diaryText,
        'date': date.toIso8601String(),
        'imageUrl': imageUrl,
        'createdAt': DateTime.now().toIso8601String(),
        'username': userName,
      }),
    );

    print('📤 캘린더 저장 요청 보냄: ${response.statusCode}');
    print('📥 응답 내용: ${response.body}');

    return response.statusCode == 200;
  }



  static Future<List<Map<String, dynamic>>?> fetchCalendar(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null){
      return null;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/calendar/$username"), // ✅ 백엔드에 맞춘 엔드포인트
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((item) => {
        'date': item['date'],
        'location': item['location'],
        'diaryText': item['diaryText'], // ✅ 백엔드 필드 이름 맞춰야 함
        'imageUrl': item['imageUrl'],   // ✅ 역시 필드 이름 일치
      }).toList();
    } else {
      print("캘린더 데이터 불러오기 실패: ${response.statusCode}");
      return null;
    }
  }


}
