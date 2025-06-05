// 📦 필요한 패키지
import 'package:flutter/material.dart';
import 'postdetail_screen.dart';
import 'spotsearch_screen.dart';
import 'mypage_screen.dart';
import 'post_screen.dart';
import 'package:charkak/services/post_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 🧩 Post 모델 정의 (이미 별도 파일에 있다면 import)
class Post {
  final int id;
  final String imageUrl;
  final String? ratingTag, countryTag, cityTag, targetTag, thumbnailUrl;

  Post({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.ratingTag,
    this.countryTag,
    this.cityTag,
    this.targetTag,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    print('[🔥 raw json] $json');

    return Post(
      id: json['id'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      ratingTag: json['ratingTagName']?.toString(), // ⭐️ 널체크 + 문자열 변환
      countryTag: json['countryTagName']?.toString(),
      cityTag: json['cityTagName']?.toString(),
      targetTag: json['targetTagName']?.toString(),
    );
  }
}

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  int _selectedIndex = 0;
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = true;

  Map<String, String?> _selectedTags = {
    '별점': null,
    '국가': null,
    '도시': null,
    '대상': null,
  };

  final List<String> starTags = ['별1개', '별2개', '별3개', '별4개', '별5개'];
  final List<String> countryTags = ['국내', '국외'];
  final Map<String, List<String>> cityOptions = {
    '국내': ['서울', '대구', '대전', '부산', '인천'],
    '국외': ['미국', '일본', '영국', '프랑스'],
  };
  final List<String> subjectTags = ['인물', '풍경', '사물', '동물', '야경'];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final postsJson = await PostService.fetchPosts();
      final posts = postsJson.map<Post>((json) => Post.fromJson(json)).toList();
      setState(() {
        _allPosts = posts;
        _filteredPosts = List.from(posts);
        _isLoading = false;
      });
    } catch (e) {
      print("❌ 게시물 불러오기 오류: $e");
      setState(() => _isLoading = false);
    }
  }

  void _applyTagFilter() {
    List<Post> filtered =
        _allPosts.where((post) {
          bool match = true;

          // ⭐ 별점 비교: '별5개' vs post.ratingTag('5') → 변환 필요
          if (_selectedTags['별점'] != null) {
            final selected = _selectedTags['별점'];
            final actual = post.ratingTag != null ? '${post.ratingTag}' : null;
            if (actual != selected) match = false;
          }

          if (_selectedTags['국가'] != null &&
              post.countryTag != _selectedTags['국가']) {
            match = false;
          }

          if (_selectedTags['도시'] != null &&
              post.cityTag != _selectedTags['도시']) {
            match = false;
          }

          if (_selectedTags['대상'] != null &&
              post.targetTag != _selectedTags['대상']) {
            match = false;
          }

          // 🔍 디버깅 로그
          print(
            '[필터링 체크] post.id=${post.id} / '
            'rating=${post.ratingTag}, country=${post.countryTag}, '
            'city=${post.cityTag}, target=${post.targetTag} => match=$match',
          );

          return match;
        }).toList();

    setState(() {
      _filteredPosts = filtered;
    });

    print('✅ 필터링 완료: ${filtered.length}개 게시물 표시됨');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth - 40) / 3;
    final imageHeight = imageWidth / 2 * 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _showTagFilterBottomSheet(context),
              child: Image.asset('assets/icons/filter.png', width: 24),
            ),
            Image.asset('assets/icons/camera_w.png', width: 35, height: 35),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostWriteScreen(),
                  ),
                );
                if (result == true) {
                  _loadPosts();
                }
              },
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // const SizedBox(height: 10),
                  Wrap(
                    spacing: 5,
                    children:
                        _selectedTags.entries
                            .where((e) => e.value != null)
                            .map((e) => _buildTag('#${e.value}'))
                            .toList(),
                  ),

                  // const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            mainAxisExtent: 200,
                          ),
                      itemCount: _filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PostDetailScreen(postId: post.id),
                              ),
                            );
                          },
                          child: Container(
                            width: imageWidth,
                            height: imageHeight,
                            color: Colors.white,
                            child: CachedNetworkImage(
                              imageUrl: post.thumbnailUrl ?? post.imageUrl,
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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

  void _showTagFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        Map<String, String?> tempSelected = Map.from(_selectedTags);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '태그 필터 설정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(
                    '별점',
                    starTags,
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '국가',
                    countryTags,
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '도시',
                    tempSelected['국가'] != null
                        ? cityOptions[tempSelected['국가']] ?? []
                        : [],
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '대상',
                    subjectTags,
                    tempSelected,
                    setModalState,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTags = tempSelected;
                        _applyTagFilter();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '적용하기',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(
    String label,
    List<String> options,
    Map<String, String?> tempSelected,
    StateSetter setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (options.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('먼저 국가를 선택하세요', style: TextStyle(color: Colors.grey)),
          ),
        Wrap(
          spacing: 8,
          children:
              options.map((option) {
                final selected = tempSelected[label] == option;
                return FilterChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: selected,
                  onSelected: (bool value) {
                    setModalState(() {
                      tempSelected[label] = value ? option : null;
                      if (label == '국가') tempSelected['도시'] = null;
                    });
                  },
                  selectedColor: Colors.black,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black, width: 1.5),
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 84, 84, 84),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color.fromARGB(255, 88, 88, 88),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
