import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'spotsearch_screen.dart';
import 'mainpage_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:charkak/services/auth_service.dart';
import 'package:charkak/services/calendar_service.dart';

class MYpageScreen extends StatefulWidget {
  const MYpageScreen({super.key});

  @override
  State<MYpageScreen> createState() => _MYpageScreenState();
}

class _MYpageScreenState extends State<MYpageScreen> {
  int _selectedIndex = 2;
  DateTime _focusedMonth = DateTime.now();
  String? _userName;
  String? _userId;
  File? _profileImage;

  final Map<String, dynamic> _calendarData = {};

  @override
  void initState() {
    super.initState();
    _loadUserDataAndCalendar(); // 통합 처리
  }

  Future<void> _loadUserDataAndCalendar() async {
    final name = await AuthService.fetchName();
    final id = await AuthService.fetchID();

    if (name != null && id != null) {
      setState(() {
        _userName = name;
        _userId = id;
      });

      final data = await CalendarService.fetchCalendar(id);
      if (data != null) {
        setState(() {
          _calendarData.clear();
          for (var item in data) {
            final date = item['date'];
            final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(date));

            _calendarData[formattedDate] = {
              'image': item['imageUrl'],
              'title': item['location'],
              'content': item['diaryText'],
            };
          }
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfile(),
            const SizedBox(height: 10),
            _buildMonthHeader(),
            const SizedBox(height: 10),
            _buildWeekDays(),
            Expanded(child: _buildCalendar()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (_selectedIndex == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPageScreen()),
              );
            } else if (_selectedIndex == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SpotSearchScreen()),
              );
            } else if (_selectedIndex == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MYpageScreen()),
              );
            }
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 0 ? 'assets/icons/home.png' : 'assets/icons/home_un.png',
              width: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1 ? 'assets/icons/marker.png' : 'assets/icons/marker_un.png',
              width: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2 ? 'assets/icons/user.png' : 'assets/icons/user_un.png',
              width: 30,
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : const AssetImage('assets/icons/user.png') as ImageProvider,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _userName ?? '...로딩 중...',
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'PretendardBold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: _showEditNameDialog,
                  ),
                ],
              ),
              Text('@${_userId ?? '...로딩 중...'}', style: const TextStyle(color: Colors.grey, fontFamily: 'PretendardRegular')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('닉네임 수정', style: TextStyle(fontSize: 20, fontFamily: 'PretendardBold')),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '새 닉네임 입력'),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('취소', style: TextStyle(fontFamily: 'PretendardSemiBold')),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text;
              final result = await AuthService.updateName(newName);

              if (result == "success") {
                setState(() {
                  _userName = newName;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? '오류 발생')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('저장', style: TextStyle(fontFamily: 'PretendardSemiBold')),
          ),

        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    String formattedMonth = DateFormat.yMMMM('ko_KR').format(_focusedMonth);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
        ),
        Text(
          formattedMonth,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((d) => Expanded(
          child: Center(
            child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ),
    );
  }
Widget _buildCalendar() {
  final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
  final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
  final firstWeekday = firstDayOfMonth.weekday % 7;
  final daysInMonth = lastDayOfMonth.day;
  final totalCells = daysInMonth + firstWeekday;

  return GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 7,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      childAspectRatio: 0.5, // 사진 비율 설정
    ),
    itemCount: totalCells,
    itemBuilder: (context, index) {
      if (index < firstWeekday) {
        return const SizedBox();
      }
      int day = index - firstWeekday + 1;
      DateTime date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      String key = DateFormat('yyyy-MM-dd').format(date);
      final data = _calendarData[key];

      return GestureDetector(
        onTap: () => _onDayTap(context, date, data),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 0.1),
          ),
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              Text(day.toString(), style: const TextStyle(fontFamily: 'PretendardSemiBold')),
              const SizedBox(height: 2),
              if (data != null && data['image'] != null && data['image'].toString().isNotEmpty)
                Expanded(
                  child: Image.network(
                    data['image'],
                    fit: BoxFit.fitWidth,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
                )
              else if (data != null && data['title'] != null && data['title'].toString().isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity, // 날짜 칸 전체 너비에 맞춤
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data['title'],
                        style: const TextStyle(fontSize: 8, fontFamily: "PretendardSemiBold"),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  ],
                )

            ],
          ),
        ),
      );
    },
  );
}

void _scheduleWrite(BuildContext context, DateTime selectedDate) {
  final TextEditingController locationController = TextEditingController();

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 표시
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMMd('ko_KR').format(selectedDate),
                    style: const TextStyle(fontSize: 16, fontFamily: 'PretendardSemiBold'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 장소 입력
              Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        hintText: "출사 장소를 입력하세요",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 저장 버튼
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    if (locationController.text.isEmpty || _userId == null) return;
                    final success = await CalendarService.saveCalendar(
                      location: locationController.text,
                      diaryText: '',
                      date: selectedDate,
                      imageUrl: '',
                      userName: _userId!,
                    );
                    if (success) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _loadUserDataAndCalendar();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("저장", style: TextStyle(fontFamily: 'PretendardSemiBold')),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _diaryWrite(BuildContext context, DateTime selectedDate, [String? initialLocation]) {
  File? selectedImage;
  final TextEditingController contentController = TextEditingController();
  final TextEditingController locationController = TextEditingController(text: initialLocation ?? "");

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 표시
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.yMMMMd('ko_KR').format(selectedDate),
                        style: const TextStyle(fontSize: 16, fontFamily: 'PretendardSemiBold'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 장소 입력
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            hintText: "출사 장소를 입력하세요",
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // 사진 업로드
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          selectedImage = File(picked.path);
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: selectedImage != null ? 300 : 200,
                      color: Colors.grey.shade200,
                      child: selectedImage != null
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

                  const Divider(height: 20),

                  // 일기 작성
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "일기를 입력하세요",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 저장 버튼
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedImage == null || locationController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("입력 오류", style: TextStyle(fontFamily: 'PretendardBold')),
                              content: const Text("사진과 장소를 모두 입력하세요."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("확인", style: TextStyle(fontFamily: 'PretendardSemiBold')),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        final imageUrl = await CalendarService.uploadImage(selectedImage!);
                        if (imageUrl == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("업로드 실패", style: TextStyle(fontFamily: 'PretendardBold')),
                              content: const Text("이미지 업로드에 실패했습니다."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("확인", style: TextStyle(fontFamily: 'PretendardSemiBold')),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        final success = await CalendarService.saveCalendar(
                          location: locationController.text,
                          diaryText: contentController.text,
                          date: selectedDate,
                          imageUrl: imageUrl,
                          userName: _userId!,
                        );

                        if (success) {
                          final key = DateFormat('yyyy-MM-dd').format(selectedDate);
                          setState(() {
                            _calendarData[key] = {
                              'image': imageUrl,
                              'title': locationController.text,
                              'content': contentController.text,
                            };
                          });

                          Navigator.pop(context);
                          Navigator.pop(context);

                          _loadUserDataAndCalendar();

                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("저장 실패", style: TextStyle(fontFamily: 'PretendardBold')),
                              content: const Text("데이터 저장에 실패했습니다."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("확인", style: TextStyle(fontFamily: 'PretendardSemiBold')),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("저장", style: TextStyle(fontFamily: 'PretendardSemiBold')),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}


  void _onDayTap(BuildContext context, DateTime date, dynamic data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // ✅ 1. 일기 작성된 경우 (image 존재)
        if (data != null && data['image'] != null && data['image'].toString().isNotEmpty) {
          print("일기 존재");
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.yMMMMd('ko_KR').format(date),
                        style: const TextStyle(fontFamily: 'PretendardSemiBold'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Text(data['title'] ?? '출사 장소',
                          style: const TextStyle(fontFamily: 'PretendardSemiBold')),
                    ],
                  ),
                  const Divider(height: 20),
                  Center(child: Image.network(data['image'], height: 300)),
                  const Divider(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        data['content'] ?? '일기 내용이 없습니다.',
                        style: const TextStyle(fontSize: 14, fontFamily: 'PretendardSemiBold'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ 2. 스케줄만 기록된 경우 (title은 있지만 image 없음)
        else if (data != null && data['title'] != null && data['title'].toString().isNotEmpty) {
          return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                DateFormat.yMMMMd('ko_KR').format(date),
                style: const TextStyle(fontSize: 16, fontFamily: 'PretendardSemiBold'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8),
              Text(
                data['title'],
                style: const TextStyle(fontSize: 16, fontFamily: 'PretendardSemiBold'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                ),
                child: const Text('닫기', style: TextStyle(fontFamily: 'PretendardSemiBold')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _diaryWrite(context, date, data['title']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('일기 작성', style: TextStyle(fontFamily: 'PretendardSemiBold')),
              ),
            ],
          )
        ],
      ),
    );
  }

        // ✅ 3. 아무 기록이 없는 날
        else {
          print("기록 없음");
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 64),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _scheduleWrite(context, date);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('일정 등록', style: TextStyle(fontFamily: 'PretendardSemiBold')),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _diaryWrite(context, date, null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('일기 작성', style: TextStyle(fontFamily: 'PretendardSemiBold')),
                ),
              ],
            ),
          );
        }
      },
    );
  }

}
