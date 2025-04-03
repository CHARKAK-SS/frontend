import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'spotsearch_screen.dart';
import 'mainpage_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MYpageScreen extends StatefulWidget {
  const MYpageScreen({super.key});

  @override
  State<MYpageScreen> createState() => _MYpageScreenState();
}

class _MYpageScreenState extends State<MYpageScreen> {
  int _selectedIndex = 2;
  DateTime _focusedMonth = DateTime.now();
  String _username = '찰칵';
  File? _profileImage;

  final Map<String, dynamic> _calendarData = {
    '2025-04-02': {'image': 'assets/samples/photo1.jpg'},
    '2025-04-08': {'image': 'assets/samples/photo2.jpg'},
    '2025-04-13': {'image': 'assets/samples/photo3.jpg'},
    '2025-04-21': {'image': 'assets/samples/photo4.jpg'},
    '2025-04-26': {
      'image': 'assets/samples/photo5.jpg',
      'title': '선유도 공원',
      'content': '오늘은 선유도 공원으로 출사를 다녀왔다. 일몰을 보면서 사진을 찍으니까 사진을 더 예쁘게 찍을 수 있었던 것 같다. 이 카메라를 처음으로 쓰는거라 아직 조작법이 익숙하지는 않지만 한 번 찍어보니까 다음에는 더 잘 찍을 수 있을 것 같다!'
    },
    '2025-04-30': {'image': 'assets/samples/photo6.jpg'},
  };

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
                  Text(_username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: _showEditNameDialog,
                  ),
                ],
              ),
              const Text('@charkac', style: TextStyle(color: Colors.grey)),
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
    final controller = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '새 닉네임 입력'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _username = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
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
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.6, //캘린더 세로 비율
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
            padding: const EdgeInsets.all(2),
            child: Column(
              children: [
                Text(day.toString()),
                if (data != null && data['image'] != null)
                  Expanded(
                    child: Image.asset(
                      data['image'],
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                  )
                else if (data != null && data['text'] != null)
                  Expanded(
                    child: Text(
                      data['text'],
                      style: const TextStyle(fontSize: 10),
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

  void _onDayTap(BuildContext context, DateTime date, dynamic data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (data != null && data['image'] != null) { //기록이 있을 때
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 128),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(DateFormat.yMMMMd('ko_KR').format(date)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Text(data['title'] ?? '출사 장소')
                    ],
                  ),
                  const Divider(height: 20),
                  Center(child: Image.asset(data['image'], height: 300)),
                  const Divider(height: 20),
                  Text(data['content'] ?? '일기 내용이 없습니다.', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 20,)
                ],
              ),
            ),
          );
        } else { //기록이 없을 때
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 64), //여백
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('일정 등록'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('일기 작성'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
