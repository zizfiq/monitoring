/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  final DatabaseReference _sensorRef =
      FirebaseDatabase.instance.ref().child('sensorData');
  final DatabaseReference _servoRef =
      FirebaseDatabase.instance.ref().child('servoControl/status');
  Map<String, dynamic> sensorData = {};
  bool servoStatus = false;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _sensorRef.once().then((DatabaseEvent event) {
        final data = event.snapshot.value as Map?;
        if (data != null) {
          setState(() {
            sensorData = Map<String, dynamic>.from(data);
          });
        }
      });

      _servoRef.once().then((DatabaseEvent event) {
        final status = event.snapshot.value;
        if (status is bool) {
          setState(() {
            servoStatus = status;
          });
        }
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

  void _activateServo() {
    _servoRef.set(true).then((_) {
      print('Servo control status updated to: ON');
      Timer(Duration(seconds: 2), () {
        _servoRef.set(false).then((_) {
          print('Servo control status updated to: OFF');
        }).catchError((error) {
          print('Failed to update status: $error');
        });
      });
    }).catchError((error) {
      print('Failed to update status: $error');
    });
  }

  String formatNumber(double value) {
    return value.toStringAsFixed(2);
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
                            title: Text('EC'),
                            subtitle: Text(
                                '${formatNumber(sensorData['EC']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: Text('TDS'),
                            subtitle: Text(
                                '${formatNumber(sensorData['TDS']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: Text('Temperature'),
                            subtitle: Text(
                                '${formatNumber(sensorData['Temperature']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: Text('pH'),
                            subtitle: Text(
                                '${formatNumber(sensorData['pH']?.toDouble() ?? 0)}'),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 20),
                          child: ListTile(
                            title: Text('Servo Control Status'),
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
}*/
