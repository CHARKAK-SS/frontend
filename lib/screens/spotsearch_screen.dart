import 'package:flutter/material.dart';
import 'mainpage_screen.dart'; // MainPageScreen 추가
import 'mypage_screen.dart';
import 'spotdetail_screen.dart'; // SpotDetailScreen 추가

class SpotSearchScreen extends StatefulWidget {
  const SpotSearchScreen({super.key});

  @override
  State<SpotSearchScreen> createState() => _SpotSearchScreenState();
}

class _SpotSearchScreenState extends State<SpotSearchScreen> {
  int _selectedIndex = 1; // marker 아이콘이 기본 선택된 상태로 시작

  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _places = [
    {'name': '드레스덴', 'address': 'Sophienstraße, 01067 Dresden'},
    {'name': '선유도 공원', 'address': '서울특별시, 영등포구, 선유로 343'},
    {'name': '호칸지', 'address': 'Higashiyama-ku, Kyoto'},
    {'name': '서울숲', 'address': '서울특별시, 성동구, 뚝섬로 273'},
  ];
  List<Map<String, String>> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _filteredPlaces = _places;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPlaces =
          _places
              .where(
                (place) =>
                    place['name']!.contains(_searchController.text) ||
                    place['address']!.contains(_searchController.text),
              )
              .toList();
    });
  }

  void _showAddPlacePopup() {
    String newName = '';
    String newAddress = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정
      builder: (_) {
        return Container(
          height: 400,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white, // 팝업 배경색
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26, // 그림자 색상
                blurRadius: 10.0, // 흐림 정도
                offset: Offset(0, -3), // 그림자 위치
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 장소명 입력 필드
              TextField(
                decoration: const InputDecoration(labelText: '장소명'),
                onChanged: (value) => newName = value,
              ),
              // 주소 입력 필드
              TextField(
                decoration: const InputDecoration(labelText: '주소'),
                onChanged: (value) => newAddress = value,
              ),
              const SizedBox(height: 20),
              // 추가 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  if (newName.isNotEmpty && newAddress.isNotEmpty) {
                    setState(() {
                      _places.add({'name': newName, 'address': newAddress});
                      _filteredPlaces = _places; // 리스트 갱신
                    });
                    Navigator.pop(context); // 팝업 닫기
                  }
                },
                child: const Text(
                  '장소 추가',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 검색바
            Container(
              color: Colors.black, // 검색 상자 밖 배경을 검정색으로 설정
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white, // 검색 상자 내부는 화이트로 설정
                  border: Border.all(
                    color: Colors.black,
                    width: 2.5,
                  ), // 검색 상자 테두리
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: '장소를 검색하세요',
                          hintStyle: TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        'assets/icons/search.png', // 검색 아이콘 이미지 변경
                        width: 20, // 아이콘 크기 줄이기
                        height: 20,
                      ),
                      onPressed: _onSearchChanged,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 2.5), // 선 두껍게
            // 장소 목록 및 추가 버튼을 ListView에 넣어 스크롤되게 함
            Expanded(
              child: ListView(
                children: [
                  // 장소 목록
                  ..._filteredPlaces.map((place) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.black12,
                        backgroundImage: AssetImage('assets/icons/marker.png'),
                      ),
                      title: Text(
                        place['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(place['address']!),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SpotDetailScreen(
                                  placeName: place['name']!, // ✅ 장소 이름 전달
                                ),
                          ),
                        );
                      },
                    );
                  }).toList(),

                  // 장소 추가 버튼
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 가로 크기를 최소화
                      mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showAddPlacePopup, // 팝업 열기
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            '장소 추가',
                            style: TextStyle(
                              fontFamily: 'PretendardBold',
                              fontSize: 14, // 버튼 글자 크기 줄임
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, // 버튼 크기 줄이기
                              vertical: 10, // 버튼 크기 줄이기
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 'marker' 아이콘이 선택된 상태로 시작
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (_selectedIndex == 0) {
              // 'home' 버튼 클릭 시 MainPageScreen으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPageScreen()),
              );
            } else if (_selectedIndex == 1) {
              // 'marker' 버튼 클릭 시 SpotSearchScreen으로 이동
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
