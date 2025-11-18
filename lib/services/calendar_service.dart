import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CalendarService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<Map<String, String>?> uploadImage(File imageFile) async {
    final uri = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(body);
        return {
          "imageUrl": jsonResponse['imageUrl'] as String,
          "thumbnailUrl": jsonResponse['thumbnailUrl'] as String,
        };
      } catch (e) {
        print("파싱 오류: 서버가 올바른 JSON을 반환하지 않았습니다. $body");
        return null;
      }
    } else {
      print("업로드 실패: ${response.statusCode}");
      return null;
    }
  }

  static Future<bool> saveCalendar({
    required String location,
    required String diaryText,
    required DateTime date,
    required String imageUrl,
    required String thumbnailUrl, 
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/api/calendar/save');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'location': location,
        'diaryText': diaryText,
        'date': date.toIso8601String(),
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'createdAt': DateTime.now().toIso8601String(),
        'username': userName,
      }),
    );
    print(userName);
    print('캘린더 저장 요청: ${response.statusCode}');
    print('response: ${response.body}');

    return response.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>?> fetchCalendar(
    String username,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/calendar/$username"), 
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList
          .map(
            (item) => {
              'date': item['date'],
              'location': item['location'],
              'diaryText': item['diaryText'], 
              'imageUrl': item['imageUrl'],
              'thumbnailUrl': item['thumbnailUrl'], 
            },
          )
          .toList();
    } else {
      print("캘린더 데이터 불러오기 실패: ${response.statusCode}");
      return null;
    }
  }
}