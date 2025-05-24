import 'package:flutter/material.dart';
import 'postdetail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:charkak/services/weather_service.dart';

class Post {
  final int id;
  final String imageUrl;
  final String? ratingTag, countryTag, cityTag, targetTag;

  Post({
    required this.id,
    required this.imageUrl,
    this.ratingTag,
    this.countryTag,
    this.cityTag,
    this.targetTag,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      imageUrl: json['imageUrl'],
      ratingTag: json['ratingTagName'],
      countryTag: json['countryTagName'],
      cityTag: json['cityTagName'],
      targetTag: json['targetTagName'],
    );
  }
}

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
  LatLng? targetLatLng;
  bool isLoadingMap = true;
  String? weatherInfo;

  List<Post> allPosts = [];
  List<Post> filteredPosts = [];
  bool isLoadingPosts = true;

  Map<String, String?> selectedTags = {
    '별점': null,
    '국가': null,
    '도시': null,
    '대상': null,
  };

  final List<String> starTags = ['별1개', '별2개', '별3개', '별4개', '별5개'];
  final List<String> countryTags = ['국내', '국외'];
  final List<String> cityTags = ['서울', '대구', '대전', '부산'];
  final List<String> subjectTags = ['인물', '풍경', '사물', '동물', '야경'];

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndLocation();
    _fetchPostsByPlace();
  }

  void _fetchWeatherAndLocation() async {
    try {
      setState(() => isLoadingMap = true);
      final result = await WeatherService.fetchWeatherAndLocation(
        widget.address,
      );
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

  Future<void> _fetchPostsByPlace() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/posts/search?placeName=${Uri.encodeComponent(widget.placeName)}',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allPosts = data.map((item) => Post.fromJson(item)).toList();
          filteredPosts = List.from(allPosts); // 🔥 초기화 시 전체 사진 출력
          isLoadingPosts = false;
        });
      } else {
        print('서버 응답 실패: ${response.statusCode}');
        setState(() => isLoadingPosts = false);
      }
    } catch (e) {
      print('포스트 불러오기 실패: $e');
      setState(() => isLoadingPosts = false);
    }
  }

  // 🔥 태그 선택 후 OR 조건으로 필터링
  // 🔥 서버에 선택된 태그 조건 포함해 재요청
  void _applyTagFilter() async {
    try {
      // 선택된 태그를 파라미터로 만듦
      String url =
          'http://10.0.2.2:8080/api/posts/search?placeName=${Uri.encodeComponent(widget.placeName)}';
      if (selectedTags['별점'] != null)
        url += '&ratingTagName=${Uri.encodeComponent(selectedTags['별점']!)}';
      if (selectedTags['국가'] != null)
        url += '&countryTagName=${Uri.encodeComponent(selectedTags['국가']!)}';
      if (selectedTags['도시'] != null)
        url += '&cityTagName=${Uri.encodeComponent(selectedTags['도시']!)}';
      if (selectedTags['대상'] != null)
        url += '&targetTagName=${Uri.encodeComponent(selectedTags['대상']!)}';

      print('🔥 서버 요청 URL: $url');

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          filteredPosts = data.map((item) => Post.fromJson(item)).toList();
        });
        print('✅ 서버에서 필터링된 게시물 수: ${filteredPosts.length}');
      } else {
        print('❌ 서버 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 태그 필터링 요청 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.placeName,
          style: const TextStyle(
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
                          liteModeEnabled: true,
                        ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.address,
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
                  ...selectedTags.entries
                      .where((e) => e.value != null)
                      .map((e) => _buildTag('${e.key}: ${e.value}'))
                      .toList(),
                ],
              ),
              const SizedBox(height: 16),
              isLoadingPosts
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ((filteredPosts.length + 2) ~/ 3) * 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          mainAxisExtent: 120,
                        ),
                    itemBuilder: (context, index) {
                      if (index < filteredPosts.length) {
                        final post = filteredPosts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PostDetailScreen(postId: post.id),
                              ),
                            );
                          },
                          child: Image.network(
                            post.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return Container(color: Colors.white);
                      }
                    },
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
        Map<String, String?> tempSelected = Map.from(selectedTags);
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
                  _buildFilterChips(
                    '별점',
                    starTags,
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '국가',
                    countryTags,
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '도시',
                    cityTags,
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '대상',
                    subjectTags,
                    tempSelected,
                    setModalState,
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
                          _applyTagFilter(); // 🔥 선택 후 필터링
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '적용하기',
                        style: TextStyle(color: Colors.white),
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

  Widget _buildFilterChips(
    String label,
    List<String> options,
    Map<String, String?> tempSelected,
    StateSetter setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children:
              options.map((option) {
                final selected = tempSelected[label] == option;
                return FilterChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (bool value) {
                    setModalState(() {
                      tempSelected[label] = value ? option : null;
                    });
                  },
                  selectedColor: Colors.black,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
      ],
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
