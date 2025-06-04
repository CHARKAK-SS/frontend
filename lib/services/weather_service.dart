import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherService {
  // 🔥 인증키는 디코딩된 버전을 그대로 넣음 (Encoding 하지 않음)
  static const String _apiKey = 'decode key';

  // 위도/경도 -> 격자 좌표 변환
  static Map<String, int> _convertToGrid(double lat, double lon) {
    const double RE = 6371.00877,
        GRID = 5.0,
        SLAT1 = 30.0,
        SLAT2 = 60.0,
        OLON = 126.0,
        OLAT = 38.0,
        XO = 43,
        YO = 136;
    double DEGRAD = pi / 180.0,
        re = RE / GRID,
        slat1 = SLAT1 * DEGRAD,
        slat2 = SLAT2 * DEGRAD,
        olon = OLON * DEGRAD,
        olat = OLAT * DEGRAD;
    double sn =
        log(cos(slat1) / cos(slat2)) /
        log(tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5));
    double sf = pow(tan(pi * 0.25 + slat1 * 0.5), sn) * cos(slat1) / sn;
    double ro = re * sf / pow(tan(pi * 0.25 + olat * 0.5), sn);
    double ra = re * sf / pow(tan(pi * 0.25 + lat * DEGRAD * 0.5), sn);
    double theta = lon * DEGRAD - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;
    int x = (ra * sin(theta) + XO + 0.5).floor();
    int y = (ro - ra * cos(theta) + YO + 0.5).floor();
    return {'nx': x, 'ny': y};
  }

  // URL 생성 시 Uri.https로 안전하게 인코딩 처리
  static String _buildUrl(int nx, int ny, DateTime time) {
    final baseDate = DateFormat('yyyyMMdd').format(time);
    final baseTime = DateFormat(
      'HHmm',
    ).format(time.subtract(const Duration(hours: 1)));

    final query = {
      'serviceKey': _apiKey, // 🔥 Uri.https가 자동으로 인코딩 처리해줌
      'numOfRows': '10',
      'pageNo': '1',
      'dataType': 'JSON',
      'base_date': baseDate,
      'base_time': baseTime,
      'nx': nx.toString(),
      'ny': ny.toString(),
    };

    return Uri.https(
      'apis.data.go.kr',
      '/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst',
      query,
    ).toString();
  }

  static Future<String?> fetchWeather(String address, DateTime time) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return '위치 변환 실패';

      final lat = locations[0].latitude;
      final lon = locations[0].longitude;
      final grid = _convertToGrid(lat, lon);
      final url = _buildUrl(grid['nx']!, grid['ny']!, time);

      print('📡 WeatherService URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200)
        return 'API 호출 실패(${response.statusCode})';

      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final items =
          (json['response']?['body']?['items']?['item'] ?? []) as List;

      if (items.isEmpty) return '날씨 데이터 없음';

      String temp = '', sky = '', pty = '';
      for (var item in items) {
        if (item['category'] == 'T1H') temp = item['obsrValue'].toString();
        if (item['category'] == 'SKY') sky = item['obsrValue'].toString();
        if (item['category'] == 'PTY') pty = item['obsrValue'].toString();
      }

      String condition =
          (pty != '0')
              ? {'1': '비', '2': '비/눈', '3': '눈', '4': '소나기'}[pty] ?? '강수'
              : {'1': '맑음', '3': '구름 많음', '4': '흐림'}[sky] ?? '맑음';

      return '$temp°C | $condition';
    } catch (e) {
      print('❌ WeatherService Error: $e');
      return '날씨 정보 불러오기 실패';
    }
  }

  static Future<String?> fetchCurrentWeather(String address) {
    return fetchWeather(address, DateTime.now());
  }

  static Future<Map<String, dynamic>> fetchWeatherAndLocation(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) throw Exception('위치 변환 실패');

      final lat = locations[0].latitude;
      final lon = locations[0].longitude;
      final weather = await fetchCurrentWeather(address);

      return {'latlng': LatLng(lat, lon), 'weather': weather};
    } catch (e) {
      print('❌ WeatherService.fetchWeatherAndLocation Error: $e');
      throw Exception('날씨 및 위치 불러오기 실패');
    }
  }
}
