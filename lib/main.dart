import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:monitoring/Screen/login.dart';
import 'package:monitoring/Screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(
      startingPage: isLoggedIn
          ? const MyHomePage(title: 'Monitoring Tambak Udang')
          : const LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget startingPage;

  const MyApp({super.key, required this.startingPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: startingPage,
      debugShowCheckedModeBanner: false,
    );
  }
}
