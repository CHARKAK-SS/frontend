import 'dart:convert';
import 'package:http/http.dart' as http;

class Spot {
  final int id;
  final String name;
  final String address;
  final String? thumbnailUrl;

  Spot({
    required this.id,
    required this.name,
    required this.address,
    this.thumbnailUrl,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
  Spot copyWith({String? thumbnailUrl}) {
    return Spot(
      id: id,
      name: name,
      address: address,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

class SpotSearchService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<List<Spot>> searchSpots(String keyword) async {
    final url = Uri.parse('$baseUrl/api/spots/search?keyword=$keyword');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decoded);
      return jsonList.map((json) => Spot.fromJson(json)).toList();
    } else {
      throw Exception('장소 검색 실패: ${response.statusCode}');
    }
  }

  static Future<List<Spot>> fetchRecentSpots({int limit = 5}) async {
    final url = Uri.parse('$baseUrl/api/spots/recent?limit=$limit');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decoded);
      return jsonList.map((json) => Spot.fromJson(json)).toList();
    } else {
      throw Exception('최근 장소 로드 실패: ${response.statusCode}');
    }
  }

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
      return false;
    } else {
      throw Exception('장소 추가 실패: ${response.statusCode} ${response.body}');
    }
  }

  static Future<String?> fetchFirstImageForPlace(String placeName) async {
    try {
      final encodedPlace = Uri.encodeComponent(placeName);
      final url =
          'http://10.0.2.2:8080/api/posts/search?placeName=$encodedPlace';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty && data[0]['imageUrl'] != null) {
          return data[0]['imageUrl'];
        }
      } else {
        print('서버 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('이미지 불러오기 실패: $e');
    }

    return null;
  }
}
