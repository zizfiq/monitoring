import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:monitoring/Screen/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp()); // Ganti dari LoginPage ke MyApp
}

// Tambahkan class MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // LoginPage sebagai halaman awal
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
    );
  }
}
