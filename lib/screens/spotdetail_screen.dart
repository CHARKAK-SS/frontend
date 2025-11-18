import 'dart:math';

import 'package:flutter/material.dart';
import 'postdetail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:charkak/services/weather_service.dart';
import 'package:charkak/services/post_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Post {
  final int id;
  final String imageUrl;
  final String? ratingTag, countryTag, cityTag, targetTag, thumbnailUrl;

  Post({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.ratingTag,
    this.countryTag,
    this.cityTag,
    this.targetTag,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
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

  Map<String, String?> selectedTags = {'별점': null, '대상': null};

  Map<String, List<dynamic>> _dynamicTagOptions = {};
  bool _tagsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndLocation();
    _fetchPostsByPlace();
    _loadAllTags();
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
          filteredPosts = List.from(allPosts);
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

  void _loadAllTags() async {
    try {
      final tagMap = await PostService.fetchTagsByCategory();
      
      setState(() {
        _dynamicTagOptions = tagMap;
        _tagsLoading = false;
      });
    } catch (e) {
      print('태그 데이터 로드 실패: $e');
      setState(() {
        _tagsLoading = false;
      });
    }
  }

  void _applyTagFilter() async {
    try {
      String url =
          'http://10.0.2.2:8080/api/posts/search?placeName=${Uri.encodeComponent(widget.placeName)}';
      if (selectedTags['별점'] != null)
        url += '&ratingTagName=${Uri.encodeComponent(selectedTags['별점']!)}';
      if (selectedTags['대상'] != null)
        url += '&targetTagName=${Uri.encodeComponent(selectedTags['대상']!)}';

      print('URL: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          filteredPosts = data.map((item) => Post.fromJson(item)).toList();
        });
        print('필터링된 게시물 수: ${filteredPosts.length}');
      } else {
        print('서버 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('태그 필터링 요청 실패: $e');
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
              const Divider(thickness: 1.5, color: Colors.black),
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showTagFilterBottomSheet(context),
                    child: Image.asset(
                      'assets/icons/bars-filter.png',
                      width: 18,
                    ),
                  ),
                  const SizedBox(width: 7),
                  ...selectedTags.entries
                      .where((e) => e.value != null)
                      .map((e) => _buildTag('#${e.value}'))
                      .toList(),
                ],
              ),
              const SizedBox(height: 16),
              isLoadingPosts
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: ((filteredPosts.length + 2) ~/ 3) * 3, 
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 0, 
                          mainAxisSpacing: 1,
                          mainAxisExtent: 185,
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
                          child: Container(
                            color: Colors.white, 
                            alignment: Alignment.center,
                            child: CachedNetworkImage( 
                            imageUrl: post.thumbnailUrl ?? post.imageUrl, 
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
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
                    _dynamicTagOptions['rating'] ?? [],
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '대상',
                    _dynamicTagOptions['target'] ?? [],
                    tempSelected,
                    setModalState,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTags = tempSelected;
                            _applyTagFilter();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '적용하기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),],),
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
    List<dynamic> options,
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
              options.map((tagDto) {
                final originalName = tagDto['name'].toString();
                final display = label == '별점' ? originalName.replaceFirst('별', '') : originalName; 
                
                final selected = tempSelected[label] == originalName;
                return FilterChip(
                  label: Text(
                    display,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: selected,
                  onSelected: (bool value) {
                    setModalState(() {
                      tempSelected[label] = value ? originalName : null;
                    });
                  },
                  selectedColor: Colors.black,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black, width: 1.5),
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
