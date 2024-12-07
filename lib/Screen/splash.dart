import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring/Screen/login.dart';
import 'package:monitoring/Screen/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create a scale animation with FastOutSlowInCurve
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // Start the animation
    _animationController.forward();

    // Navigate after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkLoginStatus();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isLoggedIn
            ? const MyHomePage(title: 'Monitoring Tambak Udang')
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'images/icon.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
