import 'package:flutter/material.dart';
import '../services/location_service.dart';

class TestWeatherPage extends StatefulWidget {
  const TestWeatherPage({Key? key}) : super(key: key);

  @override
  State<TestWeatherPage> createState() => _TestWeatherPageState();
}

class _TestWeatherPageState extends State<TestWeatherPage> {
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String? _result;
  bool _isLoading = false;

  void _fetchWeather() async {
    final address = _addressController.text.trim();
    final date = _dateController.text.trim();
    final time = _timeController.text.trim();

    if (address.isEmpty || date.isEmpty || time.isEmpty) {
      setState(() => _result = '❌ 입력값을 모두 입력하세요');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await LocationService.fetchWeather(address, date, time);
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('날씨 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: '주소 입력'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: '날짜 (yyyyMMdd)'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: '시간 (HHmm)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchWeather,
              child: const Text('날씨 조회'),
            ),
            if (_isLoading) const CircularProgressIndicator(),
            if (_result != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _result!,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
