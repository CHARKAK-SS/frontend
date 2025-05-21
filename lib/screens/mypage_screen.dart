import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'spotsearch_screen.dart';
import 'mainpage_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:charkak/services/auth_service.dart';

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

  final Map<String, dynamic> _calendarData = {
    '2025-05-02': {'image': 'assets/samples/photo1.jpg'},
    '2025-05-08': {'image': 'assets/samples/photo2.jpg'},
    '2025-05-13': {'image': 'assets/samples/photo3.jpg'},
    '2025-05-18': {'image': 'assets/samples/photo7.jpg'},
    '2025-05-21': {'image': 'assets/samples/photo4.jpg'},
    '2025-05-26': {
      'image': 'assets/samples/photo5.jpg',
      'title': '선유도 공원',
      'content': '오늘 선유도 공원으로 출사를 다녀왔다. 일몰을 보면서 사진을 찍으니까 사진을 더 예쁘게 찍을 수 있었던 것 같다. 이 카메라를 처음으로 쓰는거라 아직 조작법이 익숙하지는 않지만 한 번 찍어보니까 다음에는 더 잘 찍을 수 있을 것 같다!'
    },
    '2025-05-30': {'image': 'assets/samples/photo6.jpg'},
  };

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserid();
  }

  // AuthService에서 정보 가져오기
  Future<void> _loadUserName() async {
    final name = await AuthService.fetchName();
    if (name != null) {
      setState(() {
        _userName = name;
      });
    }
  }
  Future<void> _loadUserid() async {
    final id = await AuthService.fetchID();
    if (id != null) {
      setState(() {
        _userId = id;
      });
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
        childAspectRatio: 0.5, //photo size(smaller is bigger)
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
              border: Border.all(color: Colors.grey.shade300,width: 0.1), //calender gird
            ),
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Text(day.toString(), style: TextStyle(fontFamily: 'PretendardSemiBold')),
                if (data != null && data['image'] != null)
                  Expanded(
                    child: Image.asset(
                      data['image'],
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.low,
                    ),
                  )
                else if (data != null && data['text'] != null)
                  Expanded(
                    child: Text(
                      data['text'],
                      style: const TextStyle(fontSize: 13, fontFamily: "PretendardRegular"),
                      textAlign: TextAlign.center,
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

void _scheduleWrite(BuildContext context) {
  final TextEditingController locationController = TextEditingController();
  DateTime today = DateTime.now();

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
                    DateFormat.yMMMMd('ko_KR').format(today),
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
                  onPressed: () {
                    // 저장 로직 여기에 추가
                    Navigator.pop(context);
                    Navigator.pop(context);
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

void _diaryWrite(BuildContext context, DateTime selectedDate) {
  File? selectedImage;
  final TextEditingController contentController = TextEditingController();
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜
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
                      height: 200,
                      color: Colors.grey.shade200,
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
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
                      onPressed: () {
                        // 저장 로직 여기에
                        Navigator.pop(context);
                        Navigator.pop(context);
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
        if (data != null && data['image'] != null) {
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
                      Text(DateFormat.yMMMMd('ko_KR').format(date), style: TextStyle(fontFamily: 'PretendardSemiBold')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Text(data['title'] ?? '출사 장소', style: TextStyle(fontFamily: 'PretendardSemiBold'))
                    ],
                  ),
                  const Divider(height: 20),
                  Center(child: Image.asset(data['image'], height: 300)),
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
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 64),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _scheduleWrite(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('일정 등록', style: TextStyle(fontFamily: 'PretendardSemiBold')),
                ),
                ElevatedButton(
                  onPressed: () => _diaryWrite(context,date),
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
