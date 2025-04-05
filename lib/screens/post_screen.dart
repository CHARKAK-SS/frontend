import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지
import 'dart:io'; // 파일을 다루기 위한 패키지
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지

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

  List<File> _selectedImages = []; // 선택된 이미지를 저장할 리스트
  List<String> selectedTags = ['#풍경', '#서울', '#영등포구']; // 기본 선택된 태그

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // 이미지 선택 (갤러리)
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        // 날짜 선택 후, 시간 선택 팝업을 호출
        _selectTime(context, pickedDate);
      });
    }
  }

  // 시간 입력 함수
  Future<void> _selectTime(BuildContext context, DateTime pickedDate) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // 날짜와 시간을 합쳐서 표시
      String formattedTime = pickedTime.format(context); // hh:mm 형식

      // 날짜와 시간을 포맷해서 표시 (yyyy-MM-dd hh:mm 형식)
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      setState(() {
        _dateTimeController.text =
            "$formattedDate $formattedTime"; // 날짜와 시간 같이 표시
      });
    }
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
              // 장소 입력란
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

              // 날짜와 시간 입력란
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _dateTimeController,
                      decoration: const InputDecoration(
                        hintText: '날짜와 시간을 선택하세요',
                        border: UnderlineInputBorder(),
                      ),
                      readOnly: true, // 날짜를 직접 입력하지 못하게 함
                      onTap: () {
                        _selectDate(context); // 날짜 선택 후 시간 선택
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 카메라 종류 입력란
              Row(
                children: [
                  const Icon(Icons.camera, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _cameraController,
                      decoration: const InputDecoration(
                        hintText: '카메라 종류를 입력하세요',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 온도 입력란
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
              const SizedBox(height: 20),

              // 사진 추가
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  color: Colors.grey[200],
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 80,
                  ), // 세로 크기 늘리기
                  child: const Text(
                    '사진을 선택하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 선택된 이미지들을 보여주는 위젯
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Image.file(_selectedImages[index], fit: BoxFit.cover);
                },
              ),

              // 글 내용
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 5, // 여러 줄을 입력할 수 있게 설정
                  decoration: const InputDecoration(
                    hintText: '일기를 입력하세요',
                    border: InputBorder.none, // 내부 테두리 제거
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '태그 선택',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  // 태그 선택 (예시)
                  FilterChip(
                    label: Text('#풍경'),
                    selected: selectedTags.contains('#풍경'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedTags.add('#풍경');
                        } else {
                          selectedTags.remove('#풍경');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: Text('#서울'),
                    selected: selectedTags.contains('#서울'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedTags.add('#서울');
                        } else {
                          selectedTags.remove('#서울');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: Text('#영등포구'),
                    selected: selectedTags.contains('#영등포구'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedTags.add('#영등포구');
                        } else {
                          selectedTags.remove('#영등포구');
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // 글 작성 완료 후 처리 로직 추가
                  // 예: 입력한 제목, 내용, 이미지들을 서버에 전송
                  Navigator.pop(context); // 이전 화면으로 돌아가기
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text(
                  '게시하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
