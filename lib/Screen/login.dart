import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monitoring/Login%20With%20Google/google_auth.dart';
import 'package:monitoring/Screen/home.dart';
import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController tambakIdController =
      TextEditingController(); // New controller for ID Tambak
  final auth = FirebaseAuth.instance;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool isLoading = false;
  bool _obscureText = true; // State untuk show/hide password

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle the password visibility
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    tambakIdController.dispose(); // Dispose the new controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadLoginData();
  }

  void _loadLoginData() async {
    String? email = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');

    if (email != null && password != null) {
      emailController.text = email;
      passwordController.text = password;
    }
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    // Check if the Tambak ID is correct
    if (tambakIdController.text != '002543') {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, "ID Tambak tidak valid.");
      return;
    }

    String res = await AuthMethod().loginUser(
        email: emailController.text, password: passwordController.text);

    if (res == "success") {
      // Store login credentials if remember me is checked
      await storage.delete(key: 'email');
      await storage.delete(key: 'password');

      // Set login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyHomePage(
            title: 'Monitoring Tambak Udang',
          ),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, "Email atau kata sandi salah.");
    }
  }

  void showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    const Text(
                      "Lupa sandi?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: forgotEmailController,
                    decoration: const InputDecoration(
                      hintText: "Masukkan email",
                      prefixIcon: Icon(Icons.alternate_email),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await auth
                        .sendPasswordResetEmail(
                            email: forgotEmailController.text)
                        .then((value) {
                      showSnackBar(context,
                          "Kami sudah mengirimkan tautan untuk mereset sandi anda");
                    }).onError((error, stackTrace) {
                      showSnackBar(context, error.toString());
                    });
                    Navigator.pop(context);
                    forgotEmailController.clear();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Kirim Tautan Reset',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Aplikasi Monitoring Tambak",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'images/udang.png',
                  height: 120,
                ),
                const SizedBox(height: 40),
                // Tambak ID Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: tambakIdController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan ID Tambak',
                      prefixIcon: Icon(Icons.qr_code_2),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Email Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan email',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscureText, // Use the state for visibility
                    decoration: InputDecoration(
                      hintText: 'Masukkan sandi',
                      prefixIcon: const Icon(Icons.lock),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            _togglePasswordVisibility, // Toggle visibility
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login Button
                GestureDetector(
                  onTap: loginUser,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'MASUK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Google Sign-In Button
                GestureDetector(
                  onTap: () async {
                    // Check if the Tambak ID is empty
                    if (tambakIdController.text.isEmpty) {
                      showSnackBar(context, "ID Tambak tidak boleh kosong");
                      return;
                    }
                    // Check if the Tambak ID is correct
                    if (tambakIdController.text != '002543') {
                      showSnackBar(context, "ID Tambak tidak valid");
                      return;
                    }

                    try {
                      // Attempt Google Sign-In and check if it was successful
                      bool loginSuccess =
                          await FirebaseServices().signInWithGoogle();

                      if (loginSuccess) {
                        // Set login state for Google Sign In
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', true);

                        // Navigate to the home page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyHomePage(
                              title: 'Monitoring Tambak Udang',
                            ),
                          ),
                        );
                      } else {}
                    } catch (error) {
                      // Handle error if sign-in fails
                      showSnackBar(
                          context, "Login dibatalkan atau terjadi kesalahan");
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://lh3.googleusercontent.com/COxitqgJr1sJnIDe8-jiKhxDx1FrYbtRHKJ9z_hELisAlapwE9LUPh6fcXIfb5vwpbMl4xl9H9TRFPc5NOO8Sb3VSgIBrfRYvW6cUA',
                          height: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Lanjutkan dengan Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Row for Lupa Sandi and Daftar buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: showForgotPasswordDialog,
                      child: const Text(
                        'Lupa sandi?',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Belum punya akun? Daftar",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
