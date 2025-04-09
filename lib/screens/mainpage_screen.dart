import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'spotsearch_screen.dart';
import 'postdetail_screen.dart';
import 'mypage_screen.dart';
import 'post_screen.dart';
import 'package:charkak/services/auth_service.dart'; // ✅ AuthService import

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  int _selectedIndex = 0;
  String? _userName; // ✅ 사용자 이름

  final List<Map<String, dynamic>> _images = [
    {'postid': 1, 'image': 'assets/samples/photo1.jpg'},
    {'postid': 2, 'image': 'assets/samples/photo2.jpg'},
    {'postid': 3, 'image': 'assets/samples/photo3.jpg'},
    {'postid': 4, 'image': 'assets/samples/photo4.jpg'},
    {'postid': 5, 'image': 'assets/samples/photo5.jpg'},
    {'postid': 6, 'image': 'assets/samples/photo6.jpg'},
    {'postid': 7, 'image': 'assets/samples/photo7.jpg'},
    {'postid': 8, 'image': 'assets/samples/photo8.jpg'},
    {'postid': 9, 'image': 'assets/samples/photo9.jpg'},
    {'postid': 10, 'image': 'assets/samples/photo10.jpg'},
    {'postid': 11, 'image': 'assets/samples/photo11.jpg'},
    {'postid': 12, 'image': 'assets/samples/photo12.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ✅ AuthService에서 이름 가져오기
  Future<void> _loadUserName() async {
    final name = await AuthService.fetchName();
    if (name != null) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 20.0;
    const spacing = 0.0;
    final totalSpacing = spacing * 2;
    final availableWidth = screenWidth - (horizontalPadding * 2) - totalSpacing;
    final imageWidth = availableWidth / 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/camera_w.png', width: 35, height: 200),
          ],
        ),
        actions: [
          if (_userName != null) // ✅ 이름이 있을 때만 출력
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  _userName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'PretendardBold',
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostWriteScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          mainAxisExtent: 205,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final post = _images[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PostDetailScreen(
                        postid: post['postid'],
                        imagePath: post['image'],
                      ),
                ),
              );
            },
            child: Container(
              width: imageWidth,
              color: Colors.white,
              child: Image.asset(post['image'], fit: BoxFit.contain),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPageScreen()),
              );
            } else if (_selectedIndex == 1) {
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
