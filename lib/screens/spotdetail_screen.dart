import 'package:flutter/material.dart';
import 'postdetail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert'; // ✅
import 'dart:math'; // ✅
import 'package:http/http.dart' as http; // ✅
import 'package:intl/intl.dart'; // ✅

final List<Map<String, dynamic>> _images = [
  {'postid': 1, 'image': 'assets/samples/photo1.jpg'},
  {'postid': 2, 'image': 'assets/samples/photo2.jpg'},
  {'postid': 3, 'image': 'assets/samples/photo3.jpg'},
  {'postid': 4, 'image': 'assets/samples/photo4.jpg'},
  {'postid': 5, 'image': 'assets/samples/photo5.jpg'},
  {'postid': 6, 'image': 'assets/samples/photo6.jpg'},
  {'postid': 7, 'image': 'assets/samples/photo7.jpg'},
  {'postid': 8, 'image': 'assets/samples/photo8.jpg'},
  {'postid': 9, 'image': 'assets/samples/photo9.jpg'},
  {'postid': 10, 'image': 'assets/samples/photo10.jpg'},
  {'postid': 11, 'image': 'assets/samples/photo11.jpg'},
  {'postid': 12, 'image': 'assets/samples/photo12.jpg'},
];

class SpotDetailScreen extends StatefulWidget {
  final String placeName;
  final String address;

  const SpotDetailScreen({
    super.key,
    required this.placeName,
    required this.address,
  });

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  LatLng? targetLatLng; // ✅ 지도 위치
  bool isLoadingMap = true; // ✅ 로딩 상태

  String? weatherInfo; // ✅ 날씨 정보 표시용
  final String apiKey = '---api key'; // ✅ 기상청 API 키

  @override
  void initState() {
    super.initState();
    _convertAddressToLatLng(); // ✅ 주소 → 위치 변환 호출
  }

  // ✅ 주소 → 위도/경도 변환 함수
  void _convertAddressToLatLng() async {
    try {
      List<Location> locations = await locationFromAddress(widget.address);
      if (locations.isNotEmpty) {
        final lat = locations[0].latitude; // ✅ 추가
        final lon = locations[0].longitude; // ✅ 추가

        setState(() {
          targetLatLng = LatLng(locations[0].latitude, locations[0].longitude);
          isLoadingMap = false;
        });

        // ✅ 날씨 정보 가져오기
        final weather = await fetchWeather(apiKey, lat, lon);
        setState(() {
          weatherInfo = weather;
        });
      }
    } catch (e) {
      print('주소 변환 실패: $e');
      setState(() {
        isLoadingMap = false;
      });
    }
  }

  // ✅ 위도경도 → 격자 변환
  Map<String, int> convertToGrid(double lat, double lon) {
    const double RE = 6371.00877;
    const double GRID = 5.0;
    const double SLAT1 = 30.0;
    const double SLAT2 = 60.0;
    const double OLON = 126.0;
    const double OLAT = 38.0;
    const double XO = 43;
    const double YO = 136;
    double DEGRAD = pi / 180.0;

    double re = RE / GRID;
    double slat1 = SLAT1 * DEGRAD;
    double slat2 = SLAT2 * DEGRAD;
    double olon = OLON * DEGRAD;
    double olat = OLAT * DEGRAD;

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

  // ✅ 수정된 API URL 생성 함수 (쿼리 파라미터를 안전하게 인코딩)
  String buildKmaApiUrl(String apiKey, int nx, int ny) {
    final now = DateTime.now();
    final baseDate = DateFormat('yyyyMMdd').format(now);
    final baseTime = DateFormat(
      'HHmm',
    ).format(now.subtract(const Duration(hours: 1)));

    // ✅ 쿼리 파라미터를 Map으로 지정
    final queryParameters = {
      'serviceKey': apiKey,
      'numOfRows': '10',
      'pageNo': '1',
      'dataType': 'JSON', // ✅ 꼭 포함되어야 JSON 응답이 옵니다!
      'base_date': baseDate,
      'base_time': baseTime,
      'nx': nx.toString(),
      'ny': ny.toString(),
    };

    // ✅ Uri.https 사용으로 자동 인코딩
    return Uri.https(
      'apis.data.go.kr',
      '/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst',
      queryParameters,
    ).toString();
  }

  // ✅ 날씨 가져오기
  Future<String> fetchWeather(String apiKey, double lat, double lon) async {
    final grid = convertToGrid(lat, lon);
    final url = buildKmaApiUrl(apiKey, grid['nx']!, grid['ny']!);

    print('📡 호출 URL: $url'); // ✅ 실제 호출 URL 확인

    final response = await http.get(Uri.parse(url));

    print('📩 응답 상태코드: ${response.statusCode}'); // ✅ 200인지 확인
    print(
      '📩 응답 바디 일부: ${utf8.decode(response.bodyBytes).substring(0, min(300, response.bodyBytes.length))}',
    ); // ✅ 응답 내용 확인 (앞부분만)

    if (response.statusCode != 200) throw Exception("기상청 API 호출 실패");

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    final items = json['response']['body']['items']['item'];

    String temp = '';
    String sky = '';
    String pty = '';

    for (var item in items) {
      if (item['category'] == 'T1H') temp = item['obsrValue'].toString();
      if (item['category'] == 'SKY') sky = item['obsrValue'].toString();
      if (item['category'] == 'PTY') pty = item['obsrValue'].toString();
    }

    String condition = '';
    if (pty != '0') {
      condition = {'1': '비', '2': '비/눈', '3': '눈', '4': '소나기'}[pty] ?? '강수';
    } else {
      condition = {'1': '맑음', '3': '구름 많음', '4': '흐림'}[sky] ?? '맑음';
    }

    return '$temp°C  |  $condition';
  }

  final List<String> allTags = ['#평가', '#동물', '#건축물'];
  Set<String> selectedTags = {'#평가', '#동물', '#건축물'};

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> top3Images = _images.take(3).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 20.0;
    const spacing = 4.0;
    final totalSpacing = spacing * 2;
    final availableWidth = screenWidth - (horizontalPadding * 2) - totalSpacing;
    final imageWidth = availableWidth / 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼
          },
        ),
        title: Text(
          widget.placeName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "PretendardBold",
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child:
                    isLoadingMap
                        ? const Center(child: CircularProgressIndicator())
                        : targetLatLng == null
                        ? const Center(child: Text("지도를 불러올 수 없습니다"))
                        : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: targetLatLng!,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("spot"),
                              position: targetLatLng!,
                              infoWindow: InfoWindow(title: widget.placeName),
                            ),
                          },
                          zoomControlsEnabled: false,
                          liteModeEnabled: true, // ✅ 간단한 렌더링
                        ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.address, // ✅ 실제 주소 표시
                style: const TextStyle(fontFamily: "PretendardSemiBold"),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Image.asset('assets/icons/temperature-high.png', width: 20),
                  const SizedBox(width: 6),
                  Text(
                    weatherInfo ?? '날씨 로딩 중...',
                    style: const TextStyle(fontFamily: "PretendardRegular"),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.black),
              const SizedBox(height: 10),

              const Text(
                '혼잡도 금요일',
                style: TextStyle(
                  fontFamily: "PretendardSemiBold",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 5),
              const Text(
                '평소보다 더 혼잡',
                style: TextStyle(fontFamily: "PretendardRegular"),
              ),
              const SizedBox(height: 12),
              Image.asset(
                'assets/samples/congest_ex.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),

              const SizedBox(height: 16),
              const Divider(thickness: 1.5, color: Colors.black),
              const SizedBox(height: 10),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showTagFilterBottomSheet(context),
                    child: Image.asset(
                      'assets/icons/bars-filter.png',
                      width: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...selectedTags.map(
                    (tag) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildTag(tag),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAllPhotosBottomSheet(context, imageWidth),
                    child: Image.asset(
                      'assets/icons/angle-right.png',
                      width: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (index) {
                  final post = top3Images[index];
                  return Padding(
                    padding: EdgeInsets.only(right: index != 2 ? spacing : 0),
                    child: SizedBox(
                      width: imageWidth,
                      height: imageWidth * (3 / 2),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PostDetailScreen(
                                    postid: post['postid'],
                                    imagePath: post['image'],
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.white,
                          child: Image.asset(
                            post['image'],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        Set<String> tempSelected = {...selectedTags};
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '태그 필터 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "PretendardBold",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children:
                        allTags.map((tag) {
                          final isSelected = tempSelected.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                selected
                                    ? tempSelected.add(tag)
                                    : tempSelected.remove(tag);
                              });
                            },
                            selectedColor: Colors.black,
                            checkmarkColor: Colors.white,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Colors.black,
                                width: isSelected ? 1 : 2.5,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontFamily: "PretendardSemiBold",
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedTags = tempSelected;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '적용하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "PretenderSemiBold",
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showAllPhotosBottomSheet(BuildContext context, double imageWidth) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '전체 사진',
                style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  mainAxisExtent: 180,
                ),
                itemBuilder: (context, index) {
                  final post = _images[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PostDetailScreen(
                                postid: post['postid'],
                                imagePath: post['image'],
                              ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Image.asset(
                        post['image'],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 84, 84, 84),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color.fromARGB(255, 88, 88, 88),
          fontFamily: "PretendardSemiBold",
          fontSize: 12,
        ),
      ),
    );
  }
}
