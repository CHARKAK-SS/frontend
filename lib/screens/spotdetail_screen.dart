import 'package:flutter/material.dart';
import 'postdetail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert'; // ✅
import 'dart:math'; // ✅
import 'package:http/http.dart' as http; // ✅
import 'package:intl/intl.dart'; // ✅
import 'package:charkak/services/weather_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndLocation();
  }

  void _fetchWeatherAndLocation() async {
    try {
      setState(() => isLoadingMap = true);

      final result = await WeatherService.fetchWeatherAndLocation(
        widget.address,
      );
      // result는 {'latlng': LatLng, 'weather': String}

      setState(() {
        targetLatLng = result['latlng'];
        weatherInfo = result['weather'];
        isLoadingMap = false;
      });
    } catch (e) {
      print('날씨 및 위치 불러오기 실패: $e');
      setState(() => isLoadingMap = false);
    }
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
