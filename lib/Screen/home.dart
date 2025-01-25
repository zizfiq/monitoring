import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:monitoring/Screen/profile.dart';
import 'package:monitoring/Screen/chart.dart';
import 'package:monitoring/Screen/data.dart';
import 'package:monitoring/Widget/snackbar.dart';
import 'package:monitoring/Widget/status.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool isButtonDisabled = false;
  bool isButtonPressed = false;
  Timer? _timer;
  final String apiKey = 'AIzaSyC9kIkLAGkB0xIS31vXQ8mtqMXED9TnSQc';
  final String databaseUrl =
      'https://monitoring-2f6fc-default-rtdb.asia-southeast1.firebasedatabase.app';

  final TextEditingController _feedAmountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _startTimer();
    _requestNotificationPermission();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }

  void _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'feed_channel',
      'Feed Notifications',
      channelDescription: 'Notification for feed action',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Tambak App',
      message,
      platformChannelSpecifics,
    );
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
        isButtonDisabled = servoStatus;
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
      setState(() {
        isButtonDisabled = true;
      });
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
      setState(() {
        isButtonDisabled = false;
        isButtonPressed = false;
      });
    } else {
      print('Failed to deactivate servo');
    }
  }

  Color getParameterColor(String parameter, double value) {
    switch (parameter) {
      case 'Suhu':
        return (value < 29 || value > 32)
            ? Colors.red.shade100
            : Colors.green.shade100;
      case 'pH':
        return (value < 7.5 || value > 8.5)
            ? Colors.red.shade100
            : Colors.green.shade100;
      case 'TDS':
        return (value < 100 || value > 500)
            ? Colors.red.shade100
            : Colors.green.shade100;
      case 'EC':
        return (value < 0 || value > 5)
            ? Colors.red.shade100
            : Colors.green.shade100;
      default:
        return Colors.white;
    }
  }

  String formatNumber(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedAmountController.dispose();
    super.dispose();
  }

  String determineStatus() {
    double temperature = sensorData['Temperature']?.toDouble() ?? 0;
    double pH = sensorData['pH']?.toDouble() ?? 0;
    double tds = sensorData['TDS']?.toDouble() ?? 0;
    double ec = sensorData['EC']?.toDouble() ?? 0;

    bool isTemperatureOutOfBounds = temperature < 29 || temperature > 32;
    bool isPHOutOfBounds = pH < 7.5 || pH > 8.5;
    bool isTDSOutOfBounds = tds < 100 || tds > 500;
    bool isECOutOfBounds = ec < 0 || ec > 5;

    if (isTemperatureOutOfBounds &&
        isPHOutOfBounds &&
        isTDSOutOfBounds &&
        isECOutOfBounds) {
      return 'danger';
    } else if (isTemperatureOutOfBounds ||
        isPHOutOfBounds ||
        isTDSOutOfBounds ||
        isECOutOfBounds) {
      return 'attention';
    } else {
      return 'optimal';
    }
  }

  Widget _buildNeoBrutalismBox({
    required String label,
    required String value,
    double width = double.infinity,
  }) {
    double numericValue =
        double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

    return Container(
      width: width,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              color: getParameterColor(label, numericValue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
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
            icon: const Icon(Icons.show_chart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChartPage(title: 'Grafik')),
              );
            },
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
                      borderRadius: BorderRadius.circular(8),
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
                      '#002 - Bengkalis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomContainer(
                      status: determineStatus(),
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
                        ),
                      ),
                      Expanded(
                        child: _buildNeoBrutalismBox(
                          label: 'TDS',
                          value:
                              '${(sensorData['TDS']?.toDouble() ?? 0).round()}ppm',
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
                        ),
                      ),
                      Expanded(
                        child: _buildNeoBrutalismBox(
                          label: 'EC',
                          value:
                              formatNumber(sensorData['EC']?.toDouble() ?? 0),
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
                      borderRadius: BorderRadius.circular(8),
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
                        TextField(
                          controller: _feedAmountController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Pakan (gram)',
                            labelStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          cursorColor: Colors.black,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isButtonDisabled || isButtonPressed
                                ? null
                                : () async {
                                    if (_feedAmountController.text.isEmpty) {
                                      showSnackBar(context,
                                          'Silakan masukkan jumlah pakan terlebih dahulu');
                                      return;
                                    }
                                    isButtonPressed = true;
                                    await _activateServo();
                                    final response = await http.get(Uri.parse(
                                        '$databaseUrl/sensorData.json?auth=$apiKey'));
                                    if (response.statusCode == 200) {
                                      final sensorData =
                                          json.decode(response.body);

                                      final now = DateTime.now();
                                      final timeKey =
                                          now.millisecondsSinceEpoch.toString();

                                      await http.put(
                                        Uri.parse(
                                            '$databaseUrl/feedingData/$timeKey.json?auth=$apiKey'),
                                        body: json.encode({
                                          'timestamp': now.toIso8601String(),
                                          'feedAmount': int.tryParse(
                                                  _feedAmountController.text) ??
                                              0,
                                          'temperature':
                                              sensorData['Temperature']
                                                      ?.toDouble() ??
                                                  0,
                                          'tds':
                                              sensorData['TDS']?.toDouble() ??
                                                  0,
                                          'ph':
                                              sensorData['pH']?.toDouble() ?? 0,
                                        }),
                                      );
                                    }
                                    // Menampilkan notifikasi
                                    _showNotification(
                                        'Berhasil memberi pakan!');

                                    _feedAmountController.clear();
                                    _focusNode.unfocus();
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    isButtonPressed = false;
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isButtonDisabled ? Colors.grey : Colors.blue,
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfilePage()),
                            );
                          },
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DataPage(),
                              ),
                            );
                          },
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
