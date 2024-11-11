import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: sensorData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: const Text('EC'),
                            subtitle: Text(
                                '${formatNumber(sensorData['EC']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: const Text('TDS'),
                            subtitle: Text(
                                '${formatNumber(sensorData['TDS']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: const Text('Temperature'),
                            subtitle: Text(
                                '${formatNumber(sensorData['Temperature']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: const Text('pH'),
                            subtitle: Text(
                                '${formatNumber(sensorData['pH']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: const Text('Servo Control Status'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(servoStatus ? 'ON' : 'OFF'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _activateServo,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Feed'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
