import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<Map<String, String>?> uploadImageToS3(File imageFile) async {
    final uri = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);

    final mimeType = lookupMimeType(imageFile.path);
    final fileName = basename(imageFile.path);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        filename: fileName,
      ),
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

  static Future<List<dynamic>> fetchPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/posts/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('게시물 불러오기 실패');
    }
  }

  static Future<List<dynamic>> fetchRecommendedPosts({
    required bool excludeSelf,
    required int page,
    int size = 12, //페이지 당 사진 수
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('인증 실패: 로그인이 필요합니다.');
    }

    final url = Uri.parse(
      '$baseUrl/api/posts/recommend?page=$page&size=$size&excludeSelf=$excludeSelf',
    );
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList;
    } else if (response.statusCode == 401) {
      throw Exception('인증 실패: 토큰이 만료되었거나 유효하지 않습니다.');
    } else {
      throw Exception(
          '추천 포스트 로드 실패. 상태 코드: ${response.statusCode}');
    }
  }


  static Future<Map<String, dynamic>> fetchPostById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/posts/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded;
    } else {
      throw Exception('게시글 조회 실패');
    }
  }
  static Future<Map<String, List<dynamic>>> fetchTagsByCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    
    final response = await http.get(
      Uri.parse('$baseUrl/api/tags'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      

      return data.cast<String, List<dynamic>>(); 
    } else {
      print('태그 목록 로드 실패: ${response.statusCode}');
      throw Exception('태그 목록을 불러오지 못했습니다.');
    }
  }
}