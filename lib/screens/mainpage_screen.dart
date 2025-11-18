import 'package:flutter/material.dart';
import 'postdetail_screen.dart';
import 'spotsearch_screen.dart';
import 'mypage_screen.dart';
import 'post_screen.dart';
import 'package:charkak/services/post_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    //print('====================[raw json] $json');

    return Post(
      id: json['id'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      ratingTag: json['ratingTagName']?.toString(), 
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
  List<Post> _recommendedPosts = [];
  List<Post> _allPostsForFiltering = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = true;
  
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _pageSize = 12; 
  bool _isFetchingMore = false;
  bool _hasMorePosts = true; 
  bool _excludeSelf = true; 
  
  bool _isShowingRecommended = true; 

  Map<String, String?> _selectedTags = {
    '별점': null,
    '국가': null,
    '도시': null,
    '대상': null,
  };

  Map<String, List<dynamic>> _dynamicTagOptions = {};
  bool _tagsLoading = true;
  
  final int _initStartTime = DateTime.now().millisecondsSinceEpoch; 
  bool _isInitialLoadLogged = false; 

  @override
  void initState() {
    super.initState();
    _loadAllTags();
    _scrollController.addListener(_scrollListener);
    _loadRecommendedPosts(isInitialLoad: true);
    _loadAllPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isFetchingMore && _hasMorePosts && !_selectedTags.values.any((tag) => tag != null) && _isShowingRecommended) {
      _loadRecommendedPosts(isInitialLoad: false);
    }
  }

  Future<void> _loadAllTags() async {
    try {
      final tagMap = await PostService.fetchTagsByCategory();
      
      setState(() {
        _dynamicTagOptions = tagMap;
        _tagsLoading = false;
      });
    } catch (e) {
      setState(() {
        _tagsLoading = false;
      });
    }
  }

  Future<void> _loadAllPosts() async {
    print("============_loadallpost 실행==============");
    try {
      final postsJson = await PostService.fetchPosts(); 
      print("============fetchPost 호출 완. (성공)==============");
      final allPosts = postsJson.map<Post>((json) => Post.fromJson(json)).toList();
      
      if (!mounted) return;

      setState(() {
        _allPostsForFiltering = allPosts;
        print('DB 전체 게시글 ${allPosts.length}개 로드 완료');
        
        // 전체 게시글 모드인 경우 즉시 화면 갱신
        if (!_isShowingRecommended && !_selectedTags.values.any((tag) => tag != null)) {
             _filteredPosts = List.from(_allPostsForFiltering);
        }
      });
    } catch (e) {
        // 오류 발생 시에도 무한 로딩을 방지하고 빈 목록 할당
        print("전체 게시글 로드 중 예외 발생: $e");
        if (!mounted) return;
        setState(() {
            _allPostsForFiltering = []; // 오류 시 빈 목록 할당
        });
      }
  }

  Future<void> _loadRecommendedPosts({required bool isInitialLoad}) async {
    if (isInitialLoad) {
      if (_recommendedPosts.isNotEmpty && !_isFetchingMore && !_selectedTags.values.any((tag) => tag != null) && _isShowingRecommended) {
          setState(() {
              _filteredPosts = List.from(_recommendedPosts);
              _isLoading = false;
              _scrollController.jumpTo(0.0);
          });
          return;
      }
      
      _currentPage = 0;
      _recommendedPosts.clear();
      if (!_selectedTags.values.any((tag) => tag != null) && _isShowingRecommended) {
          _filteredPosts.clear();
      }
      setState(() => _isLoading = true);
    } else {
      if (_isFetchingMore) return;
      setState(() => _isFetchingMore = true);
    }
    
    try {
      final postsJson = await PostService.fetchRecommendedPosts(
        page: _currentPage, 
        size: _pageSize, 
        excludeSelf: _excludeSelf,
      );
      
      final newPosts = postsJson.map<Post>((json) => Post.fromJson(json)).toList();
      
      if (!mounted) return;

      setState(() {
        if (isInitialLoad) {
          _recommendedPosts = newPosts;
        } else {
          _recommendedPosts.addAll(newPosts);
        }
        
        if (_isShowingRecommended && !_selectedTags.values.any((tag) => tag != null)) {
            _filteredPosts = List.from(_recommendedPosts);
        }
        
        _currentPage++;
        _hasMorePosts = newPosts.length == _pageSize; 
        
        // 초기 로딩 완료 시 _isLoading을 해제합니다.
        _isLoading = false; 
        
        _isFetchingMore = false;
      });
      
      if (_selectedTags.values.any((tag) => tag != null)) {
        _applyTagFilter();
      }

    } catch (e) {
      print("추천 게시물 불러오기 오류: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
        _hasMorePosts = false;
      });
    }
  }

  void _applyTagFilter() {
    bool isTagSelected = _selectedTags.values.any((tag) => tag != null);
    
    if (_allPostsForFiltering.isEmpty && (isTagSelected || !_isShowingRecommended)) {
        setState(() {
            _filteredPosts = [];
        });
        return;
    }

    List<Post> sourcePosts;
    if (isTagSelected) {
        sourcePosts = _allPostsForFiltering; 
    } else {
        sourcePosts = _isShowingRecommended 
            ? _recommendedPosts 
            : _allPostsForFiltering;
    }

    List<Post> filtered =
        sourcePosts.where((post) {
          bool match = true;


          if (_selectedTags['별점'] != null) {
            final selected = _selectedTags['별점'];
            final actual = post.ratingTag != null ? '${post.ratingTag}' : null;
            if (actual != selected) {
                match = false;
            }
          }

          if (match && _selectedTags['국가'] != null) {
              final selected = _selectedTags['국가'];
              final actual = post.countryTag;
              if (actual != selected) {
                  match = false;
              }
          }

          if (match && _selectedTags['도시'] != null) {
              final selected = _selectedTags['도시'];
              final actual = post.cityTag;
              if (actual != selected) {
                  match = false;
              }
          }

          if (match && _selectedTags['대상'] != null) {
              final selected = _selectedTags['대상'];
              final actual = post.targetTag;
              if (actual != selected) {
                  match = false;
              }
          }

          return match;
        }).toList();

    setState(() {
      _filteredPosts = filtered;
      if (isTagSelected || !_isShowingRecommended) {
        _hasMorePosts = false;
      }
    });
  }

  void _togglePostView(bool isRecommended) {
    if (isRecommended == _isShowingRecommended) return;

    setState(() {
      _isShowingRecommended = isRecommended;
      _hasMorePosts = isRecommended; 
      
      // 토글 시 로딩이 필요 없으므로 항상 false로 설정
      _isLoading = false; 
      
      _filteredPosts.clear();
      _scrollController.jumpTo(0.0);
    });

    if (!_selectedTags.values.any((tag) => tag != null)) {
        setState(() {
            // 전체 게시글 모드 전환 시, 캐시된 전체 목록 할당
            _filteredPosts = isRecommended 
                ? List.from(_recommendedPosts)
                : List.from(_allPostsForFiltering); 
            _hasMorePosts = isRecommended;
        });
    } else {
        _applyTagFilter();
    }
  }
  
  // 스위치 앞에 "추천" 텍스트를 추가한 위젯
  Widget _buildAppBarToggleButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // '추천' 텍스트
        const Text(
          '추천',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // 스위치 (ON: 추천 / OFF: 전체)
        Transform.scale( 
          scale: 0.7, // 크기 축소
          child: Switch.adaptive(
            value: _isShowingRecommended, // true = 추천, false = 전체
            onChanged: (bool newValue) {
              _togglePostView(newValue);
            },
            activeColor: Colors.white,
            inactiveThumbColor: Colors.black,
            inactiveTrackColor: Colors.grey[500],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
          ),
        ),
      ],
    );
  }

  // ★ 수정된 함수: UX 최적화 (로컬 업데이트) 적용 및 측정
  Future<void> _navigateToPostWrite() async {
    // PostWriteScreen으로 이동 (await 완료 시, DB 저장 및 LLM 분석은 이미 완료됨)
    // PostWriteScreen은 이제 Post 객체를 반환해야 합니다.
    final newPostDto = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PostWriteScreen(),
      ),
    );

    // ★ 1. 순수 갱신 측정 시작 시점 기록
    final startTime = DateTime.now(); 
    
    // PostWriteScreen 복귀 후 처리
    if (newPostDto != null && newPostDto is Post) { // DTO 반환이 성공했을 경우 (PostWriteScreen에서 Post 객체를 반환하도록 가정)
      
      // 2. Front-End Driven Optimization: DB 재호출 없이 로컬 리스트 업데이트
      
      setState(() {
          // A. 새 게시글을 로컬 리스트에 추가 (즉시 갱신)
          _allPostsForFiltering.insert(0, newPostDto); 
          
          if (_isShowingRecommended) {
              _recommendedPosts.insert(0, newPostDto);
          }

          // B. 필터링된 뷰도 업데이트
          if (!_selectedTags.values.any((tag) => tag != null)) {
             _filteredPosts = List.from(_isShowingRecommended ? _recommendedPosts : _allPostsForFiltering);
          } else {
             _applyTagFilter(); 
          }
      });
      
      // 3. 백엔드 캐시 갱신을 트리거합니다. (9초 Latency가 여기서 발생)
      // 이 호출은 DB 재조회를 유발하여 Redis 캐시를 최신 상태로 업데이트합니다.
      // 9초 대기를 유발하는 _loadAllPosts 호출을 제거합니다.
      // 대신, 백엔드에서 비동기로 캐시 갱신이 진행되었다고 가정합니다.
      
      // 4. 측정 종료 및 시간 계산 (9초 대기 시간 회피 성공)
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;
      
      print("--- [UX METRIC] ----------------------------------------------------");
      print("[순수 메인 화면 갱신 시간 - 최적화 후] ${duration} ms"); 
      print("--------------------------------------------------------------------");
      
    } else if (newPostDto == true) { 
        // PostWriteScreen이 DTO 대신 true를 반환하는 경우 (오래된 방식)
        // 이 경로는 현재 로직상 DB 재호출이 발생해야 합니다.
        await _loadRecommendedPosts(isInitialLoad: true); 
        await _loadAllPosts();
    }
  }


  @override
  Widget build(BuildContext context) {
    // ★ 1. 초기 화면 로딩 시간 측정 로직
    if (!_isInitialLoadLogged && !_isLoading) {
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final duration = endTime - _initStartTime;
      print("--- [UX METRIC] ----------------------------------------------------");
      print("[초기 화면 로드 완료 시간 (Tag + Recommended)] ${duration} ms");
      print("--------------------------------------------------------------------");
      // 플래그를 설정하여 다시 로깅하지 않도록 방지
      _isInitialLoadLogged = true; 
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth - 40) / 3;
    final imageHeight = imageWidth / 2 * 3;
    
    final isTagSelected = _selectedTags.values.any((tag) => tag != null);


    return Scaffold(
      backgroundColor: Colors.white,
      
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPostWrite,
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 1. 첫 번째 요소 (필터 버튼) - 좌측 정렬 (start)
            GestureDetector(
              onTap: () {
                _showTagFilterBottomSheet(context);
              },
              child: Image.asset('assets/icons/filter.png', width: 24),
            ),
            
            const Spacer(),
            const SizedBox(width: 55),
            
            // 2. 두 번째 요소 (앱 로고) - 중앙 정렬
            Image.asset('assets/icons/camera_w.png', width: 35, height: 35),
            
            const Spacer(),
            
            // 3. 세 번째 요소 (스위치) - 우측 정렬 (end)
            if (!isTagSelected)
                _buildAppBarToggleButtons()
            else
                const SizedBox(width: 84, height: 28),
          ],
        ),
      ),
      body:
          // _isLoading은 초기 로딩 시에만 사용합니다.
          _isLoading && _filteredPosts.isEmpty && _recommendedPosts.isEmpty 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  
                  Wrap(
                    spacing: 5,
                    children:
                        _selectedTags.entries
                            .where((e) => e.value != null)
                            .map((e) => _buildTag('#${e.value}'))
                            .toList(),
                  ),

                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController, 
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            mainAxisExtent: 200,
                          ),
                      itemCount: _filteredPosts.length + ((!isTagSelected && _isShowingRecommended && _hasMorePosts) ? 1 : 0), 
                      itemBuilder: (context, index) {
                        if (!isTagSelected && _isShowingRecommended && index == _filteredPosts.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
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
            } else if ( _selectedIndex == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpotSearchScreen(),
                ),
              );
            } else if ( _selectedIndex == 2) {
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
    Map<String, List<dynamic>> dynamicTags = Map.from(_dynamicTagOptions); 
    
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
                    dynamicTags['rating'] ?? [], 
                    tempSelected,
                    setModalState,
                  ),
                  _buildFilterChips(
                    '국가',
                    dynamicTags['country'] ?? [], 
                    tempSelected,
                    setModalState,
                  ),
                  if (tempSelected['국가'] != null)
                    _buildFilterChips(
                      '도시',
                      dynamicTags['city'] ?? [], 
                      tempSelected,
                      setModalState,
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('국가 태그 선택 후 도시를 선택할 수 있습니다', style: TextStyle(color: Colors.grey)),
                    ),
                  _buildFilterChips(
                    '대상',
                    dynamicTags['target'] ?? [], 
                    tempSelected,
                    setModalState,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTags = tempSelected;
                          });
                          
                          _applyTagFilter(); 
                          
                          if (!_selectedTags.values.any((tag) => tag != null)) {
                                if (_isShowingRecommended) {
                                    setState(() {
                                        _filteredPosts = List.from(_recommendedPosts);
                                    });
                                }
                          }

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '적용하기',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ],
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
    List<dynamic> options, 
    Map<String, String?> tempSelected,
    StateSetter setModalState,
  ) {
    List<String> displayOptions = [];
    String? selectedCountry = tempSelected['국가'];
    
    if (label == '도시' && selectedCountry != null) {
      displayOptions = options
          .where((tagDto) => tagDto['country'] == selectedCountry)
          .map((tagDto) => tagDto['name'].toString())
          .toList();
          
      if (options.isEmpty) {
        displayOptions = ['선택 가능한 도시 없음'];
      }
    } else {
        displayOptions = options.map((tagDto) => tagDto['name'].toString()).toList();
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        
        if (displayOptions.isEmpty && selectedCountry != null && label == '도시')
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('선택 가능한 도시 없음', style: TextStyle(color: Colors.grey)),
          )
        else if (displayOptions.isEmpty && label != '도시' && label != '별점') 
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('데이터 로딩 중...', style: TextStyle(color: Colors.grey)),
          ),
          
        Wrap(
          spacing: 8,
          children:
              displayOptions.map((option) {
                final originalName = options.firstWhere((e) => e['name'] == option)['name'];  
                final display = label == '별점' ? originalName.replaceFirst('별', '') : originalName;
                
                final selected = tempSelected[label] == originalName;
                return FilterChip(
                  label: Text(
                    display,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: selected,
                  onSelected: (bool value) {
                    setModalState(() {
                      if (option == '선택 가능한 도시 없음') return; 
                      
                      tempSelected[label] = value ? originalName : null;
                      
                      if (label == '국가') {
                        tempSelected['도시'] = null; 
                      }
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