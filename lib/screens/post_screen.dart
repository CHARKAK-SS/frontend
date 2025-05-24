import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:charkak/services/spotsearch_service.dart';
import 'search_postcode_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charkak/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<File> _selectedImages = [];
  List<String> starTags = ['별1개', '별2개', '별3개', '별4개', '별5개'];
  List<String> countryTags = ['국내', '국외'];
  List<String> cityTags = ['서울', '대구', '대전', '부산'];
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

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
                      child: const Text('장소 추가'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
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
                final result = [
                  modelCtrl.text,
                  focalCtrl.text.isNotEmpty ? '${focalCtrl.text}mm' : null,
                  apertureCtrl.text.isNotEmpty ? 'F${apertureCtrl.text}' : null,
                  shutterCtrl.text.isNotEmpty ? '1/${shutterCtrl.text}s' : null,
                  isoCtrl.text.isNotEmpty ? 'ISO${isoCtrl.text}' : null,
                ].whereType<String>().join(' | ');
                setState(() => _cameraController.text = result);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('글 작성'),
        centerTitle: true,
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
              buildUnderlineTextField(
                Icons.thermostat,
                '온도를 입력하세요',
                _temperatureController,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  buildTagDropdown('별점', starTags),
                  buildTagDropdown('국가', countryTags),
                  buildTagDropdown('도시', cityTags),
                  buildTagDropdown('대상', subjectTags),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('사진을 선택하세요')),
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder:
                    (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImages[index],
                        fit: BoxFit.cover,
                      ),
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
      print('🔑 저장된 토큰: $token'); // ⭐️ 토큰 출력

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인이 필요합니다')));
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/user/info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('🌐 유저 정보 응답 코드: ${response.statusCode}');
      print('🌐 유저 정보 응답 바디: ${response.body}');

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('유저 정보를 가져오지 못했습니다')));
        return;
      }

      final userData = jsonDecode(response.body);
      final userId = userData['id'];
      print('👤 유저 ID: $userId'); // ⭐️ userId 출력

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
        "camera": _cameraController.text,
        "lens": "",
        "aperture": "",
        "shutterSpeed": "",
        "iso": "",
        "weather": _temperatureController.text,
        "imageUrl": "http://example.com/image.jpg",
        "text": _contentController.text,
        "userId": userId,
        "ratingTagName": selectedTagMap['별점'] ?? "",
        "countryTagName": selectedTagMap['국가'] ?? "",
        "cityTagName": selectedTagMap['도시'] ?? "",
        "targetTagName": selectedTagMap['대상'] ?? "",
      };

      print('📦 전송할 데이터: $postData'); // ⭐️ POST 데이터 출력

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
        Navigator.pop(context);
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
        ),
      ),
    );
  }

  Widget buildTagDropdown(String label, List<String> items) {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => selectedTagMap[label] = value),
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
}
