import 'package:flutter/material.dart';
import 'package:charkak/services/post_service.dart';
import 'spotdetail_screen.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Map<String, dynamic>> _postFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = PostService.fetchPostById(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ 에러 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('게시글을 불러올 수 없습니다.'));
          }

          final post = snapshot.data!;
          final String placeName = post['placeName'] ?? '장소 없음';
          final String address = post['placeName'] ?? '장소 없음';
          final String? placepoint = post['placepoint'];
          final String dateTimeRaw = post['dateTime'] ?? '';
          final String dateTime =
              dateTimeRaw.isNotEmpty
                  ? DateFormat(
                    'yyyy-MM-dd HH:mm',
                  ).format(DateTime.parse(dateTimeRaw).toLocal())
                  : '';
          final String camera = post['camera'] ?? '';
          final String lens = post['lens'] ?? '';
          final String aperture = post['aperture'] ?? '';
          final String shutterSpeed = post['shutterSpeed'] ?? '';
          final String iso = post['iso'] ?? '';
          final String cameraInfo = [
            if (camera.isNotEmpty) camera,
            if (lens.isNotEmpty) '${lens}mm', // mm 단위 추가
            if (aperture.isNotEmpty) 'F$aperture', // F 단위 추가
            if (shutterSpeed.isNotEmpty) '1/${shutterSpeed}s', // s 단위 추가
            if (iso.isNotEmpty) 'ISO$iso', // ISO 추가
          ].join(' | ');
          final String weather = post['wearther'] ?? '';
          final String imageUrl = post['imageUrl'] ?? '';
          final String content = post['text'] ?? '';

          final List<String> tags = [
            if (post['ratingTag'] != null) '#${post['ratingTag']}',
            if (post['countryTag'] != null) '#${post['countryTag']}',
            if (post['cityTag'] != null) '#${post['cityTag']}',
            if (post['targetTag'] != null) '#${post['targetTag']}',
          ];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SpotDetailScreen(
                                    placeName: placeName,
                                    address: address,
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          placeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PretendardSemiBold',
                          ),
                        ),
                      ),
                      if (placepoint != null && placepoint.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            placepoint,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'PretendardRegular',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 8),
                      Text(
                        dateTime,
                        style: const TextStyle(fontFamily: 'PretendardRegular'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.photo_camera),
                      const SizedBox(width: 8),
                      Text(
                        cameraInfo,
                        style: const TextStyle(fontFamily: 'PretendardRegular'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.thermostat),
                      const SizedBox(width: 8),
                      Text(
                        weather,
                        style: const TextStyle(fontFamily: 'PretendardRegular'),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const Divider(height: 32),
                    Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: tags.map((tag) => _buildTag(tag)).toList(),
                      ),
                    ),
                  ],
                  const Divider(height: 32),
                  Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 350,
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'PretendardRegular',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
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
