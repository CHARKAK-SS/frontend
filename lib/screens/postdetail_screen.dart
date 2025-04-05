import 'package:flutter/material.dart';
import 'spotdetail_screen.dart';


final List<Map<String, dynamic>> posts = [
  {
    'postid': 1,
    'place': '선유도 공원',
    'placepoint': '37.5427533, 126.8963748',
    'dateTime': '2024. 05. 04. 18:58',
    'cameraInfo': 'NIKON Z5 | 62mm | F4.0 | 1/500s | ISO250',
    'weather': '21.4°C | 흐림',
    'tags': ['#풍경', '#서울', '#영등포구', '#별4개'],
    'content': '노을이 지는 시간대에 가면 사진이 너무 예쁘게 나와요. ...',
  },
  {
    'postid': 2,
    'place': '서울숲',
    'dateTime': '2024. 04. 22. 16:12',
    'cameraInfo': 'Canon EOS R6 | 35mm | F2.8 | 1/250s | ISO400',
    'weather': '17.8°C | 맑음',
    'tags': ['#풍경', '#서울', '#성동구', '#별3개'],
    'content': '봄날의 서울숲은 꽃이 만발해 사진 찍기 좋아요.',
  },
  {
    'postid': 3,
    'place': '올림픽공원',
    'placepoint': '37.5206868,127.1193054',
    'dateTime': '2024. 04. 10. 13:30',
    'cameraInfo': 'Sony A7M4 | 85mm | F1.8 | 1/320s | ISO200',
    'weather': '20.1°C | 구름 많음',
    'tags': ['#인물', '#서울', '#송파구', '#별5개'],
    'content': '사람 적은 평일 낮 시간에 오면 아주 한적하고 좋아요.',
  },
  {
    'postid': 4,
    'place': '한강 반포지구',
    'dateTime': '2024. 04. 05. 19:20',
    'cameraInfo': 'Fuji XT-30 | 23mm | F2.0 | 1/100s | ISO640',
    'weather': '18.9°C | 맑음',
    'tags': ['#야경', '#서울', '#성동구', '#별3개'],
    'content': '달빛 무지개 분수가 아주 예뻤어요. 추천합니다!',
  },
  {
    'postid': 5,
    'place': '북서울 꿈의숲',
    'dateTime': '2024. 03. 28. 14:05',
    'cameraInfo': 'Canon 90D | 50mm | F1.4 | 1/250s | ISO160',
    'weather': '16.2°C | 흐림',
    'tags': ['#자연', '#서울', '#성동구', '#별3개'],
    'content': '사람이 적고 조용해서 힐링에 좋아요.',
  },
  {
    'postid': 6,
    'place': '경복궁',
    'dateTime': '2024. 03. 15. 11:00',
    'cameraInfo': 'Sony A6400 | 35mm | F2.8 | 1/400s | ISO100',
    'weather': '19.3°C | 맑음',
    'tags': ['#인물', '#서울', '#성동구', '#별4개'],
    'content': '한복 입고 방문하면 사진이 정말 잘 나와요!',
  },
  {
    'postid': 7,
    'place': '양재 시민의숲',
    'dateTime': '2024. 03. 09. 10:42',
    'cameraInfo': 'Nikon D750 | 85mm | F2.2 | 1/640s | ISO200',
    'weather': '14.7°C | 맑음',
    'tags': ['#동물', '#서울', '#성동구', '#별3개'],
    'content': '잔디밭에서 돗자리 펴고 쉬기 좋아요.',
  },
  {
    'postid': 8,
    'place': '서울 대공원',
    'dateTime': '2024. 03. 02. 15:30',
    'cameraInfo': 'Canon M50 | 24mm | F3.5 | 1/200s | ISO320',
    'weather': '13.0°C | 흐림',
    'tags': ['#동물', '#서울', '#성동구', '#별3개'],
    'content': '사진 찍을 포인트가 많아요. 특히 벚꽃 시즌 추천!',
  },
  {
    'postid': 9,
    'place': '남산타워',
    'dateTime': '2024. 02. 25. 18:00',
    'cameraInfo': 'Sony RX100 | 28mm | F2.0 | 1/80s | ISO800',
    'weather': '11.5°C | 구름 많음',
    'tags': ['#야경', '#서울', '#중구', '#별3개'],
    'content': '전망대에서 보는 야경이 진짜 끝내줘요!',
  },
  {
    'postid': 10,
    'place': '인왕산',
    'dateTime': '2024. 02. 10. 06:48',
    'cameraInfo': 'Nikon Z6 | 35mm | F8.0 | 1/125s | ISO200',
    'weather': '3.2°C | 맑음',
    'tags': ['#자연', '#서울', '#성동구', '#별3개'],
    'content': '힘들게 올라간 보람이 있는 일출 뷰!',
  },
  {
    'postid': 11,
    'place': '성수동 카페거리',
    'dateTime': '2024. 01. 30. 16:10',
    'cameraInfo': 'Nikon Z50 | 26mm | F1.5 | 1/200s | ISO100',
    'weather': '6.0°C | 흐림',
    'tags': ['#사물', '#서울', '#성동구', '#별3개'],
    'content': '카페마다 포토존이 많아서 사진 찍기 좋아요.',
  },
  {
    'postid': 12,
    'place': '하늘공원',
    'placepoint': '35.167599, 129.056755',
    'dateTime': '2024. 01. 15. 17:45',
    'cameraInfo': 'Canon EOS RP | 70mm | F4.5 | 1/500s | ISO250',
    'weather': '2.0°C | 맑음',
    'tags': ['#노을', '#서울', '#성동구', '#별3개'],
    'content': '노을 질 때 억새밭이 진짜 영화 같아요.',
  },
];


class PostDetailScreen extends StatelessWidget {
  final int postid;
  final String imagePath;

  const PostDetailScreen(
    {
    super.key, 
    required this.postid,
    required this.imagePath
    });

  @override
  Widget build(BuildContext context) {
    // 더미 데이터에서 postid로 해당 post를 찾음
    final post = posts.firstWhere((element) => element['postid'] == postid);

    final String placeName = post['place'];
    final String? placepoint = post['placepoint'];
    final String dateTime = post['dateTime'];
    final String cameraInfo = post['cameraInfo'];
    final String weather = post['weather'];
    final List<String> tags = List<String>.from(post['tags']);
    final String content = post['content'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
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
                          builder: (context) => SpotDetailScreen(placeName: placeName),
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
              const Divider(height: 32),
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: tags.map((tag) => _buildTag(tag)).toList(),
                ),
              ),
              const Divider(height: 32),
              Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 350,
                ),
              ),
              const Divider(height: 32),
              Text(
                content,
                style: const TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
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