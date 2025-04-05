import 'package:flutter/material.dart';
import 'spotsearch_screen.dart'; // SpotSearchScreen 추가
import 'postdetail_screen.dart';
import 'mypage_screen.dart';
import 'post_screen.dart'; // PostWriteScreen을 위한 import 추가

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  int _selectedIndex = 0;

  final List<String> _images = [
    'assets/samples/photo1.jpg',
    'assets/samples/photo2.jpg',
    'assets/samples/photo3.jpg',
    'assets/samples/photo4.jpg',
    'assets/samples/photo5.jpg',
    'assets/samples/photo6.jpg',
    'assets/samples/photo7.jpg',
    'assets/samples/photo8.jpg',
    'assets/samples/photo9.jpg',
    'assets/samples/photo10.jpg',
    'assets/samples/photo11.jpg',
    'assets/samples/photo12.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 20.0;
    const spacing = 0.0; // 여백을 0으로 설정
    final totalSpacing = spacing * 2;
    final availableWidth = screenWidth - (horizontalPadding * 2) - totalSpacing;
    final imageWidth = availableWidth / 3; // 3개의 이미지를 균등하게 나누기

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // flexibleSpace를 사용하여 로고를 중앙에 배치하고 + 버튼은 오른쪽에 위치시킴
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/camera_w.png', width: 35, height: 200),
          ],
        ),
        actions: [
          // + 버튼을 오른쪽에 추가하고 버튼 크기를 키움
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ), // + 버튼 크기 증가
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const PostWriteScreen(), // PostWriteScreen으로 이동
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: spacing, // 여백을 0으로 설정
          mainAxisSpacing: spacing, // 여백을 0으로 설정
          mainAxisExtent: 205, // 고정된 세로 크기
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PostDetailScreen(imagePath: _images[index]),
                ),
              );
            },
            child: Container(
              width: imageWidth,
              color: Colors.white, // 빈 공간을 흰 배경으로 채우기
              child: Image.asset(
                _images[index],
                fit: BoxFit.contain, // 원본 비율을 유지
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (_selectedIndex == 0) {
              // home 아이콘 선택 시
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPageScreen()),
              );
            } else if (_selectedIndex == 1) {
              // marker 아이콘 선택 시
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpotSearchScreen(),
                ),
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
            icon:
                _selectedIndex == 0
                    ? Image.asset('assets/icons/home.png', width: 30)
                    : Image.asset('assets/icons/home_un.png', width: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                _selectedIndex == 1
                    ? Image.asset('assets/icons/marker.png', width: 30)
                    : Image.asset('assets/icons/marker_un.png', width: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon:
                _selectedIndex == 2
                    ? Image.asset('assets/icons/user.png', width: 30)
                    : Image.asset('assets/icons/user_un.png', width: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}
