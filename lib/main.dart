import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Tambahkan ini untuk Timer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  final DatabaseReference _sensorRef =
      FirebaseDatabase.instance.ref().child('sensorData');
  Map<String, dynamic> sensorData = {};
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _sensorRef.once().then((DatabaseEvent event) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          sensorData = data;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
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
      body: Center(
        child: sensorData.isEmpty
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('EC: ${sensorData['EC'] ?? 'Loading...'}'),
                  Text('TDS: ${sensorData['TDS'] ?? 'Loading...'}'),
                  Text(
                      'Temperature: ${sensorData['Temperature'] ?? 'Loading...'}'),
                  Text('pH: ${sensorData['pH'] ?? 'Loading...'}'),
                  Text(
                      'Servo Control Status: ${sensorData['servoControl'] ?? 'Loading...'}'),
                ],
              ),
      ),
    );
  }
}
