import 'package:flutter/material.dart';
import 'spotsearch_screen.dart'; // SpotSearchScreen 추가
import 'postdetail_screen.dart';
import 'mypage_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Image.asset(
            'assets/icons/camera_w.png',
            width: 30,
            height: 30,
          ),
        ),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(
                    imagePath: _images[index],
                  ),
                ),
              );
            },
            child: Image.asset(
              _images[index],
              fit: BoxFit.contain,
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
