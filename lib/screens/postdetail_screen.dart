 import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String imagePath;

  const PostDetailScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  Icon(Icons.location_on),
                  SizedBox(width: 8),
                  Text(
                    '선유도 공원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PretendardSemiBold',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.access_time),
                  SizedBox(width: 8),
                  Text(
                    '2024. 05. 04. 18:58',
                    style: TextStyle(fontFamily: 'PretendardRegular'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.photo_camera),
                  SizedBox(width: 8),
                  Text(
                    'NIKON Z5 | 62mm | F4.0 | 1/500s | ISO250',
                    style: TextStyle(fontFamily: 'PretendardRegular'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.thermostat),
                  SizedBox(width: 8),
                  Text(
                    '21.4°C | 흐림',
                    style: TextStyle(fontFamily: 'PretendardRegular'),
                  ),
                ],
              ),
              const Divider(height: 32),
              Wrap(
                spacing: 8,
                children: const [
                  Chip(label: Text('#풍경')),
                  Chip(label: Text('#서울')),
                  Chip(label: Text('#영등포구')),
                  Chip(label: Text('#별4개')),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '노을이 지는 시간대에 가면 사진이 너무 예쁘게 나와요. 풍경을 찍기에 제일 좋은 곳이라서 망원렌즈 가져오시면 더 찍기 좋을 것 같아요!\n\n제가 방문했던 날은 흐려서 사진찍기 애매했는데도 좋은 사진 건질 수 있었어요. 다들 예쁜 사진 찍으시길 바라요😊',
                style: TextStyle(fontSize: 14, fontFamily: 'PretendardRegular'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}