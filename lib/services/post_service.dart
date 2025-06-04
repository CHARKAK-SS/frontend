import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<String?> uploadImageToS3(File imageFile) async {
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
      return body; // 업로드된 이미지 URL이 문자열로 반환됨
    } else {
      print("❌ 이미지 업로드 실패: ${response.statusCode}");
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

    // 수정
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('게시물 불러오기 실패');
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
}
