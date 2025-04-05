import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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

  List<File> _selectedImages = [];
  List<String> selectedTags = [];

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectTime(context, pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime pickedDate) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      String formattedTime = pickedTime.format(context);
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _dateTimeController.text = "$formattedDate $formattedTime";
      });
    }
  }

  void _showCameraSpecDialog() {
    final TextEditingController modelCtrl = TextEditingController();
    final TextEditingController focalCtrl = TextEditingController();
    final TextEditingController apertureCtrl = TextEditingController();
    final TextEditingController shutterCtrl = TextEditingController();
    final TextEditingController isoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '카메라 정보',
            textAlign: TextAlign.center, // ✅ 중앙 정렬
            style: TextStyle(fontFamily: "pretendardBold", fontSize: 20),
          ),
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
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: apertureCtrl,
                  decoration: const InputDecoration(labelText: '조리개'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: shutterCtrl,
                  decoration: const InputDecoration(labelText: '셔터스피드'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: isoCtrl,
                  decoration: const InputDecoration(labelText: 'ISO'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // ✅ 입력 버튼 가운데 정렬
          actions: [
            ElevatedButton(
              onPressed: () {
                String result = [
                  modelCtrl.text,
                  focalCtrl.text.isNotEmpty ? '${focalCtrl.text}mm' : null,
                  apertureCtrl.text.isNotEmpty ? 'F${apertureCtrl.text}' : null,
                  shutterCtrl.text.isNotEmpty ? '1/${shutterCtrl.text}s' : null,
                  isoCtrl.text.isNotEmpty ? 'ISO${isoCtrl.text}' : null,
                ].whereType<String>().join(' | ');
                setState(() {
                  _cameraController.text = result;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ), // ✅ 검정색 버튼
              child: const Text(
                '입력',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "PretendardSemiBold",
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTagDropdown(String label, List<String> items) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 40),
        onSelected: (value) {
          setState(() {
            selectedTagMap[label] = value;
          });
        },
        itemBuilder: (BuildContext context) {
          return items.map((tag) {
            return PopupMenuItem<String>(value: tag, child: Text(tag));
          }).toList();
        },
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
                selectedTagMap[label] != null
                    ? '#${selectedTagMap[label]}'
                    : label,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
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
        title: const Text('글 작성'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _placeController,
                      decoration: const InputDecoration(
                        hintText: '장소를 입력하세요',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _dateTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: '날짜 및 시간',
                        border: UnderlineInputBorder(),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.camera_alt, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showCameraSpecDialog,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _cameraController,
                          decoration: const InputDecoration(
                            hintText: '카메라 종류를 입력하세요',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _temperatureController,
                      decoration: const InputDecoration(
                        hintText: '온도를 입력하세요',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildTagDropdown('별점', starTags),
                    buildTagDropdown('국가', countryTags),
                    buildTagDropdown('도시', cityTags),
                    buildTagDropdown('대상', subjectTags),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  color: Colors.grey[200],
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
                itemBuilder: (context, index) {
                  return Image.file(_selectedImages[index], fit: BoxFit.cover);
                },
              ),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    '게시하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
