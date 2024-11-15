import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade400),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Monitoring Tambak Udang'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> sensorData = {};
  bool servoStatus = false;
  Timer? _timer;
  final String apiKey = 'AIzaSyC9kIkLAGkB0xIS31vXQ8mtqMXED9TnSQc';
  final String databaseUrl =
      'https://monitoring-2f6fc-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchSensorData();
      _fetchServoStatus();
    });
  }

  Future<void> _fetchSensorData() async {
    final response =
        await http.get(Uri.parse('$databaseUrl/sensorData.json?auth=$apiKey'));
    if (response.statusCode == 200) {
      setState(() {
        sensorData = json.decode(response.body);
      });
    } else {
      print('Failed to load sensor data');
    }
  }

  Future<void> _fetchServoStatus() async {
    final response = await http
        .get(Uri.parse('$databaseUrl/servoControl/status.json?auth=$apiKey'));
    if (response.statusCode == 200) {
      setState(() {
        servoStatus = json.decode(response.body);
      });
    } else {
      print('Failed to load servo status');
    }
  }

  Future<void> _activateServo() async {
    final response = await http.put(
      Uri.parse('$databaseUrl/servoControl/status.json?auth=$apiKey'),
      body: json.encode(true),
    );
    if (response.statusCode == 200) {
      print('Servo control status updated to: ON');
      Timer(const Duration(seconds: 2), _deactivateServo);
    } else {
      print('Failed to activate servo');
    }
  }

  Future<void> _deactivateServo() async {
    final response = await http.put(
      Uri.parse('$databaseUrl/servoControl/status.json?auth=$apiKey'),
      body: json.encode(false),
    );
    if (response.statusCode == 200) {
      print('Servo control status updated to: OFF');
    } else {
      print('Failed to deactivate servo');
    }
  }

  String formatNumber(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildNeoBrutalismBox({
    required String label,
    required String value,
    Color labelBackgroundColor = Colors.white,
    double width = double.infinity,
  }) {
    return Container(
      width: width,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: labelBackgroundColor,
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: sensorData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      '#002 - Kelapapati Laut',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNeoBrutalismBox(
                          label: 'Suhu',
                          value:
                              '${formatNumber(sensorData['Temperature']?.toDouble() ?? 0)}°C',
                          labelBackgroundColor: Colors.blue.shade100,
                        ),
                      ),
                      Expanded(
                        child: _buildNeoBrutalismBox(
                          label: 'TDS',
                          value:
                              '${formatNumber(sensorData['TDS']?.toDouble() ?? 0)}ppm',
                          labelBackgroundColor: Colors.green.shade100,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNeoBrutalismBox(
                          label: 'pH',
                          value:
                              formatNumber(sensorData['pH']?.toDouble() ?? 0),
                          labelBackgroundColor: Colors.green.shade100,
                        ),
                      ),
                      Expanded(
                        child: _buildNeoBrutalismBox(
                          label: 'EC',
                          value:
                              formatNumber(sensorData['EC']?.toDouble() ?? 0),
                          labelBackgroundColor: Colors.orange.shade100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Isi Pakan pada Anco',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Untuk melihat nafsu makan pada udang',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _activateServo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Colors.black, width: 2),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Beri pakan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Colors.black, width: 2),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Profil',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Colors.black, width: 2),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
