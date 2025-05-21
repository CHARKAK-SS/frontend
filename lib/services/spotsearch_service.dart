import 'dart:convert';
import 'package:http/http.dart' as http;

class Spot {
  final int id;
  final String name;
  final String address;
  final String? imageUrl;

  Spot({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      imageUrl: json['imageUrl'],
    );
  }
}

class SpotSearchService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // 🔍 키워드로 장소 검색
  static Future<List<Spot>> searchSpots(String keyword) async {
    final url = Uri.parse('$baseUrl/api/spots/search?keyword=$keyword');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes); // ✅ 올바른 인코딩 방식
      final List<dynamic> jsonList = jsonDecode(decoded);
      return jsonList.map((json) => Spot.fromJson(json)).toList();
    } else {
      throw Exception('장소 검색 실패: ${response.statusCode}');
    }
  }

  // ➕ 장소 추가
  static Future<bool> addSpot(String name, String address) async {
    final url = Uri.parse('$baseUrl/api/spots');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'address': address}),
    );

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 409) {
      return false; // 중복된 장소
    } else {
      throw Exception('장소 추가 실패: ${response.statusCode} ${response.body}');
    }
  }
}
