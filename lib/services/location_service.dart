import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

const String googleApiKey = 'google api key';
const String weatherApiKey = 'weather api key';

final List<Map<String, dynamic>> observationStations = [
  {'stnId': '108', 'name': '서울', 'lat': 37.5665, 'lon': 126.9780},
  {'stnId': '133', 'name': '대전', 'lat': 36.351, 'lon': 127.385},
  {'stnId': '159', 'name': '부산', 'lat': 35.1796, 'lon': 129.0756},
];

class LocationService {
  static Future<Map<String, double>?> getCoordinates(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey',
    );
    final response = await http.get(url);
    print('📡 요청 URL: $url');
    print('📡 응답 코드: ${response.statusCode}');
    print('📡 응답 내용: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return {'lat': location['lat'], 'lon': location['lng']};
      }
    }
    print('❌ 주소 변환 실패');
    return null;
  }

  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static String findNearestStation(double lat, double lon) {
    double minDistance = double.infinity;
    String nearestStnId = '';
    for (var station in observationStations) {
      final distance = haversine(lat, lon, station['lat'], station['lon']);
      if (distance < minDistance) {
        minDistance = distance;
        nearestStnId = station['stnId'];
      }
    }
    return nearestStnId;
  }

  static Future<String> fetchWeather(
    String address,
    String date,
    String time,
  ) async {
    final coordinates = await getCoordinates(address);
    if (coordinates == null) {
      return '❌ 주소 변환 실패';
    }

    String stnId = findNearestStation(coordinates['lat']!, coordinates['lon']!);
    String tm = date + (time.length < 4 ? time.padLeft(4, '0') : time); // 시간 보정

    final url = Uri.parse(
      'https://apihub.kma.go.kr/api/typ01/url/kma_sfctm2.php'
      '?tm=$tm&stn=$stnId&authKey=$weatherApiKey&help=0',
    );
    final response = await http.get(url);
    print('📡 요청 URL: $url');
    print('📡 응답 코드: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = response.body;
      print('📡 응답 내용: $data');
      final startIndex = data.indexOf('#START7777');
      final endIndex = data.indexOf('#7777END');
      if (startIndex != -1 && endIndex != -1) {
        final content =
            data.substring(startIndex + '#START7777'.length, endIndex).trim();
        print('📌 파싱된 데이터: $content');
        final lines = content.split('\n');
        if (lines.length >= 2) {
          // 브라우저 데이터 기준으로 헤더 컬럼 인덱스 지정
          final headerIndex = {
            'TA': 11, // 기온 (섭씨)
            'WP': 23, // GTS 과거일기
            'WW': 24, // 국내식 일기코드
          };
          final values =
              lines.last
                  .split(RegExp(r'\s+'))
                  .where((v) => v.isNotEmpty)
                  .toList();
          print('📌 파싱된 값: $values');

          String temperature =
              values.length > headerIndex['TA']!
                  ? '${values[headerIndex['TA']!]}°C'
                  : '정보 없음';

          // WP를 기준으로 판단: -9는 맑음, 끝자리가 3~9는 해당 기상코드
          String weather = '맑음';
          if (values.length > headerIndex['WP']!) {
            String wp = values[headerIndex['WP']!];
            if (wp != '-9') {
              String code = wp.length >= 2 ? wp.substring(wp.length - 1) : wp;
              weather =
                  {
                    '3': '황사',
                    '4': '안개',
                    '5': '가랑비',
                    '6': '비',
                    '7': '눈',
                    '8': '소나기',
                    '9': '뇌전',
                  }[code] ??
                  '강수';
            }
          }

          return '🌡️ 기온: $temperature\n🌦️ 날씨: $weather';
        } else {
          return '❌ 데이터 파싱 실패: 줄이 부족함';
        }
      } else {
        return '❌ START/END 구간 없음';
      }
    }
    return '❌ 날씨 조회 실패: ${response.statusCode}';
  }
}
