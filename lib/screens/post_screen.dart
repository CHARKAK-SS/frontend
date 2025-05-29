import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:charkak/services/spotsearch_service.dart';
import 'search_postcode_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charkak/services/auth_service.dart';
import 'package:charkak/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charkak/services/post_service.dart';

class PostWriteScreen extends StatefulWidget {
  const PostWriteScreen({super.key});

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _cameraController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? selectedImage;
  List<String> starTags = ['별1개', '별2개', '별3개', '별4개', '별5개'];
  List<String> countryTags = ['국내', '국외'];
  final Map<String, List<String>> cityOptions = {
    '국내': ['서울', '대구', '대전', '부산', '인천', '광주', '천안', '원주', '구미', '세종', '경주'],
    '국외': ['미국', '캐나다', '영국', '독일', '스페인', '일본', '중국', '베트남', '태국'],
  };
  List<String> subjectTags = ['인물', '풍경', '사물', '동물', '야경'];

  Map<String, String?> selectedTagMap = {
    '별점': null,
    '국가': null,
    '도시': null,
    '대상': null,
  };

  String? _selectedAddress;
  int? _selectedSpotId;

  List<Spot> spots = [];
  bool noResults = false;

  // 🔥 카메라 정보 입력값 저장 변수 추가
  String? cameraModel, lens, aperture, shutterSpeed, iso;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      _selectTime(context, pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime pickedDate) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      final formattedTime = pickedTime.format(context);
      setState(() {
        _dateTimeController.text = '$formattedDate $formattedTime';
      });
    }
  }

  void _showSpotSearchPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('장소 검색'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: '장소 검색',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            try {
                              final results =
                                  await SpotSearchService.searchSpots(
                                    _searchController.text,
                                  );
                              setModalState(() {
                                spots = results;
                                noResults = spots.isEmpty;
                              });
                            } catch (e) {
                              print('검색 실패: $e');
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          noResults
                              ? const Center(child: Text('검색 결과 없음'))
                              : ListView.builder(
                                itemCount: spots.length,
                                itemBuilder: (context, index) {
                                  final spot = spots[index];
                                  return ListTile(
                                    title: Text(spot.name),
                                    subtitle: Text(spot.address),
                                    onTap: () {
                                      setState(() {
                                        _placeController.text = spot.name;
                                        _selectedAddress = spot.address;
                                        _selectedSpotId = spot.id;
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddPlacePopup();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        '장소 추가',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddPlacePopup() {
    _nameController.clear();
    _addressController.clear();
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '장소명'),
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchPostcodePage(),
                      ),
                    );
                    if (result != null && result is String) {
                      setState(() => _addressController.text = result);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(hintText: '주소를 검색하세요'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    final address = _addressController.text.trim();
                    if (name.isNotEmpty && address.isNotEmpty) {
                      final success = await SpotSearchService.addSpot(
                        name,
                        address,
                      );
                      Navigator.pop(context);
                      if (success) {
                        setState(() {
                          _placeController.text = name;
                          _selectedAddress = address;
                        });
                      } else {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(content: Text('이미 등록된 장소입니다.')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    '장소 추가',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCameraSpecDialog() {
    final modelCtrl = TextEditingController();
    final focalCtrl = TextEditingController();
    final apertureCtrl = TextEditingController();
    final shutterCtrl = TextEditingController();
    final isoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카메라 정보', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: modelCtrl,
                  decoration: const InputDecoration(labelText: '카메라 기종'),
                ),
                TextField(
                  controller: focalCtrl,
                  decoration: const InputDecoration(labelText: '초점거리'),
                ),
                TextField(
                  controller: apertureCtrl,
                  decoration: const InputDecoration(labelText: '조리개'),
                ),
                TextField(
                  controller: shutterCtrl,
                  decoration: const InputDecoration(labelText: '셔터스피드'),
                ),
                TextField(
                  controller: isoCtrl,
                  decoration: const InputDecoration(labelText: 'ISO'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // 🔥 입력값 변수에 저장 (DB에 분리 저장)
                setState(() {
                  cameraModel = modelCtrl.text;
                  lens = focalCtrl.text;
                  aperture = apertureCtrl.text;
                  shutterSpeed = shutterCtrl.text;
                  iso = isoCtrl.text;
                  // 🔥 UI에 표시할 요약 문자열
                  _cameraController.text = [
                    if (cameraModel != null && cameraModel!.isNotEmpty)
                      cameraModel,
                    if (lens != null && lens!.isNotEmpty) '${lens}mm',
                    if (aperture != null && aperture!.isNotEmpty) 'F$aperture',
                    if (shutterSpeed != null && shutterSpeed!.isNotEmpty)
                      '1/${shutterSpeed}s',
                    if (iso != null && iso!.isNotEmpty) 'ISO$iso',
                  ].join(' | ');
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('입력', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // country 선택 시 선택된 도시를 초기화하고 옵션 동적 반영
  Widget buildTagDropdown(String label, List<String> items) {
    // 🔥 country 옵션일 경우 동적 반영
    if (label == '도시') {
      final selectedCountry = selectedTagMap['국가'];
      items =
          selectedCountry != null
              ? cityOptions[selectedCountry] ?? []
              : ['국가 선택 후 도시 선택']; // 기본값 표시
    }

    return PopupMenuButton<String>(
      color: Colors.white,
      offset: Offset(0, 40),
      onSelected: (value) {
        setState(() {
          selectedTagMap[label] = value;
          if (label == '국가') {
            // 🔥 국가 변경 시 도시 초기화
            selectedTagMap['도시'] = null;
          }
        });
      },
      itemBuilder:
          (_) =>
              items
                  .map((e) => PopupMenuItem(value: e, child: Text(e)))
                  .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedTagMap[label] ?? label,
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildUnderlineTextField(
                Icons.location_on,
                '장소를 입력하세요',
                _placeController,
                onTap: _showSpotSearchPopup,
              ),
              buildUnderlineTextField(
                Icons.access_time,
                '날짜 및 시간',
                _dateTimeController,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              buildUnderlineTextField(
                Icons.camera_alt,
                '카메라 종류를 입력하세요',
                _cameraController,
                readOnly: true,
                onTap: _showCameraSpecDialog,
              ),
              buildUnderlineTextFieldWithButton(
                Icons.thermostat,
                '온도를 입력하세요',
                _temperatureController,
                onPressed: _fetchWeatherAndFillTemperature,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  buildTagDropdown('별점', starTags),
                  buildTagDropdown('국가', countryTags),
                  buildTagDropdown('도시', []), // 🔥 수정
                  buildTagDropdown('대상', subjectTags),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      selectedImage = File(picked.path);
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: selectedImage != null ? 300 : 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child:
                      selectedImage != null
                          ? Center(
                            child: Image.file(
                              selectedImage!,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                          )
                          : const Center(child: Text("사진을 선택하세요")),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(hintText: '내용을 입력하세요'),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('게시하기', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('🔑 저장된 토큰: $token');

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인이 필요합니다')));
        return;
      }

      // 🔥 유저 ID 가져오기 (fetchID 사용)
      final userId = await AuthService.fetchID();
      print('👤 유저 ID: $userId');
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('유저 정보를 가져오지 못했습니다')));
        return;
      }

      // ✅ 이미지 선택 여부 확인
      if (selectedImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('사진을 선택하세요')));
        return;
      }

      // ✅ 이미지 S3 업로드
      final imageUrl = await PostService.uploadImageToS3(selectedImage!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 업로드에 실패했습니다')));
        return;
      }

      // 🔥 입력값 유효성 검사 추가
      if (_placeController.text.trim().isEmpty ||
          _dateTimeController.text.trim().isEmpty ||
          (cameraModel == null || cameraModel!.isEmpty) ||
          (lens == null || lens!.isEmpty) ||
          (aperture == null || aperture!.isEmpty) ||
          (shutterSpeed == null || shutterSpeed!.isEmpty) ||
          (iso == null || iso!.isEmpty) ||
          _temperatureController.text.trim().isEmpty ||
          _contentController.text.trim().isEmpty ||
          selectedTagMap['별점'] == null ||
          selectedTagMap['국가'] == null ||
          selectedTagMap['도시'] == null ||
          selectedTagMap['대상'] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('모든 입력값과 태그를 선택해야 합니다')));
        return;
      }

      String dateTime = _dateTimeController.text
          .replaceAll('오전', 'AM')
          .replaceAll('오후', 'PM');
      DateTime parsedDate = DateFormat('yyyy-MM-dd h:mm a').parse(dateTime);
      String formattedDateTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(parsedDate);

      Map<String, dynamic> postData = {
        "placeName": _placeController.text,
        "dateTime": formattedDateTime,
        "camera": cameraModel ?? "",
        "lens": lens ?? "",
        "aperture": aperture ?? "",
        "shutterSpeed": shutterSpeed ?? "",
        "iso": iso ?? "",
        "weather": _temperatureController.text,
        "imageUrl": imageUrl,
        "text": _contentController.text,
        "userId": userId,
        "ratingTagName": selectedTagMap['별점'] ?? "",
        "countryTagName": selectedTagMap['국가'] ?? "",
        "cityTagName": selectedTagMap['도시'] ?? "",
        "targetTagName": selectedTagMap['대상'] ?? "",
      };

      print('📦 전송할 데이터: $postData');

      var postResponse = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(postData),
      );

      print('🌐 게시 응답 코드: ${postResponse.statusCode}');
      print('🌐 게시 응답 바디: ${postResponse.body}');

      if (postResponse.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('게시 성공!')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시 실패: ${postResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('🚨 오류 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('네트워크 오류: $e')));
    }
  }

  Widget buildUnderlineTextField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint, // 🪄 hintText 지정
          border: UnderlineInputBorder(), // ✅ Underline 추가!
        ),
      ),
    );
  }

  // 🔥 수정된 부분: 날씨 입력란 우측 버튼 포함 함수 추가
  Widget buildUnderlineTextFieldWithButton(
    IconData icon,
    String hint,
    TextEditingController controller, {
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.black),
                hintText: hint,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  // 🔥 수정된 부분: 날씨 자동입력 로직 추가
  Future<void> _fetchWeatherAndFillTemperature() async {
    final address = _selectedAddress ?? _placeController.text.trim();
    final dateTimeInput = _dateTimeController.text.trim();

    if (address.isEmpty || dateTimeInput.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('주소와 날짜/시간을 입력하세요')));
      return;
    }

    try {
      DateTime parsedDate = DateFormat(
        'yyyy-MM-dd h:mm a',
      ).parse(dateTimeInput.replaceAll('오전', 'AM').replaceAll('오후', 'PM'));
      if (parsedDate.minute > 0) {
        parsedDate = parsedDate
            .add(Duration(hours: 1))
            .subtract(Duration(minutes: parsedDate.minute));
      }
      final date = DateFormat('yyyyMMdd').format(parsedDate);
      final time = DateFormat('HH00').format(parsedDate);

      print('🌐 자동입력: 장소명: ${_placeController.text}');
      print('🌐 자동입력: 주소: $address');
      print('🌐 자동입력: 요청 시간: $date $time');

      final result = await LocationService.fetchWeather(address, date, time);
      print('🌐 자동입력: 날씨 응답: $result');

      setState(() {
        _temperatureController.text = result.replaceAll('\n', ' ');
      });
    } catch (e) {
      print('🚨 자동입력 오류: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('날씨 자동 입력 오류: $e')));
    }
  }
}
