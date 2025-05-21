import 'package:flutter/material.dart';
import 'package:charkak/services/spotsearch_service.dart';
import 'search_postcode_page.dart';
import 'mainpage_screen.dart';
import 'mypage_screen.dart';
import 'spotdetail_screen.dart';

class SpotSearchScreen extends StatefulWidget {
  const SpotSearchScreen({super.key});

  @override
  State<SpotSearchScreen> createState() => _SpotSearchScreenState();
}

class _SpotSearchScreenState extends State<SpotSearchScreen> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController =
      TextEditingController(); // ✅ 장소명
  final TextEditingController _addressController =
      TextEditingController(); // ✅ 주소

  List<Spot> _spots = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() => _spots = []);
      return;
    }

    try {
      final results = await SpotSearchService.searchSpots(keyword);
      setState(() => _spots = results);
    } catch (e) {
      print('검색 실패: $e');
    }
  }

  void _showAddPlacePopup() {
    _nameController.clear();
    _addressController.clear();

    final parentContext = context; // ✅ 팝업 바깥 context 저장

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: '장소명'),
                      style: const TextStyle(fontFamily: 'PretendardBold'),
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
                          setModalState(() {
                            _addressController.text = result;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: '주소',
                            hintText: '주소를 검색하세요',
                          ),
                          style: const TextStyle(fontFamily: 'PretendardBold'),
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
                          Navigator.pop(context); // ✅ 먼저 팝업 닫기

                          if (success) {
                            _onSearchChanged(); // ✅ 성공 시 목록 갱신
                          } else {
                            // ✅ 팝업 닫은 후 알림 띄우기 (바깥 context 사용)
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '이미 등록된 장소입니다.',
                                  style: TextStyle(
                                    fontFamily: 'PretendardBold',
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.black,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        '장소 추가',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'PretendardRegular',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'PretendardRegular',
                        ),
                        decoration: const InputDecoration(
                          hintText: '장소를 검색하세요',
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        'assets/icons/search.png',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: _onSearchChanged,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 2.5),
            Expanded(
              child: ListView(
                children: [
                  ..._spots.map((spot) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.black12,
                        backgroundImage: AssetImage('assets/icons/marker.png'),
                      ),
                      title: Text(
                        spot.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PretendardBold',
                        ),
                      ),
                      subtitle: Text(
                        spot.address,
                        style: const TextStyle(fontFamily: 'PretendardLight'),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => SpotDetailScreen(placeName: spot.name),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _showAddPlacePopup,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          '장소 추가',
                          style: TextStyle(
                            fontFamily: 'PretendardBold',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainPageScreen()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SpotSearchScreen()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MYpageScreen()),
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
              _selectedIndex == 0
                  ? 'assets/icons/home.png'
                  : 'assets/icons/home_un.png',
              width: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1
                  ? 'assets/icons/marker.png'
                  : 'assets/icons/marker_un.png',
              width: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2
                  ? 'assets/icons/user.png'
                  : 'assets/icons/user_un.png',
              width: 30,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
