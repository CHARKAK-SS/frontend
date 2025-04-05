import 'package:flutter/material.dart';

class SpotDetailScreen extends StatefulWidget {
  final String placeName;

  const SpotDetailScreen({super.key, required this.placeName});

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  final List<String> allTags = ['#평가', '#동물', '#건축물'];
  Set<String> selectedTags = {'#평가', '#동물', '#건축물'};

  final List<String> allImages = [
    'assets/samples/photo1.jpg',
    'assets/samples/photo2.jpg',
    'assets/samples/photo3.jpg',
    'assets/samples/photo4.jpg',
    'assets/samples/photo5.jpg',
    'assets/samples/photo6.jpg',
    'assets/samples/photo7.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> top3Images = allImages.take(3).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 20.0;
    const spacing = 4.0;
    final totalSpacing = spacing * 2;
    final availableWidth = screenWidth - (horizontalPadding * 2) - totalSpacing;
    final imageWidth = availableWidth / 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼
          },
        ),
        title: Text(
          widget.placeName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "PretendardBold",
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/samples/map_ex.png',
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '서울특별시, 영등포구, 선유로 343',
                style: TextStyle(fontFamily: "PretendardSemiBold"),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Image.asset(
                    'assets/icons/temperature-high.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '12.3°C  |  흐림',
                    style: TextStyle(fontFamily: "PretendardRegular"),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.black),
              const SizedBox(height: 10),

              const Text(
                '혼잡도 금요일',
                style: TextStyle(
                  fontFamily: "PretendardSemiBold",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              const Divider(thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 5),
              const Text(
                '평소보다 더 혼잡',
                style: TextStyle(fontFamily: "PretendardRegular"),
              ),
              const SizedBox(height: 12),
              Image.asset(
                'assets/samples/congest_ex.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),

              const SizedBox(height: 16),
              const Divider(thickness: 1.5, color: Colors.black),
              const SizedBox(height: 10),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showTagFilterBottomSheet(context),
                    child: Image.asset(
                      'assets/icons/bars-filter.png',
                      width: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...selectedTags.map(
                    (tag) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildTag(tag),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAllPhotosBottomSheet(context, imageWidth),
                    child: Image.asset(
                      'assets/icons/angle-right.png',
                      width: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index != 2 ? spacing : 0),
                    child: SizedBox(
                      width: imageWidth,
                      height: imageWidth * (3 / 2),
                      child: Container(
                        color: Colors.white,
                        child: Image.asset(
                          top3Images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        Set<String> tempSelected = {...selectedTags};
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '태그 필터 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "PretendardBold",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children:
                        allTags.map((tag) {
                          final isSelected = tempSelected.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                selected
                                    ? tempSelected.add(tag)
                                    : tempSelected.remove(tag);
                              });
                            },
                            selectedColor: Colors.black,
                            checkmarkColor: Colors.white,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Colors.black,
                                width: isSelected ? 1 : 2.5,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontFamily: "PretendardSemiBold",
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedTags = tempSelected;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '적용하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "PretenderSemiBold",
                        ),
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

  void _showAllPhotosBottomSheet(BuildContext context, double imageWidth) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '전체 사진',
                style: TextStyle(fontSize: 18, fontFamily: 'PretendardBold'),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1, // ✅ 간격 줄이기
                  mainAxisSpacing: 1,
                  mainAxisExtent: 180, // ✅ 고정된 높이로 설정
                ),
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.white, // ✅ 비어있는 영역을 흰색으로
                    alignment: Alignment.center,
                    child: Image.asset(
                      allImages[index],
                      fit: BoxFit.contain, // ✅ 원본 비율 유지
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
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
          fontFamily: "PretendardSemiBold",
          fontSize: 12,
        ),
      ),
    );
  }
}
