// login.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monitoring/Login%20With%20Google/google_auth.dart';
import 'package:monitoring/Screen/home.dart';
import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup.dart';
import '../Widget/interface.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController tambakIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? emailError;
  String? passwordError;
  String? tambakIdError;

  final auth = FirebaseAuth.instance;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool isLoading = false;
  bool _obscureText = true;

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    tambakIdController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool validateFields() {
    bool isValid = true;
    setState(() {
      emailError = null;
      passwordError = null;
      tambakIdError = null;

      if (tambakIdController.text.isEmpty) {
        tambakIdError = "ID Tambak harus diisi";
        isValid = false;
      } else if (tambakIdController.text != '002543') {
        tambakIdError = "ID Tambak tidak valid";
        isValid = false;
      }

      if (emailController.text.isEmpty) {
        emailError = "Email harus diisi";
        isValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(emailController.text)) {
        emailError = "Format email tidak valid";
        isValid = false;
      }

      if (passwordController.text.isEmpty) {
        passwordError = "Kata sandi harus diisi";
        isValid = false;
      } else if (passwordController.text.length < 6) {
        passwordError = "Kata sandi minimal 6 karakter";
        isValid = false;
      }
    });
    return isValid;
  }

  void loginUser() async {
    if (!validateFields()) return;

    setState(() {
      isLoading = true;
    });

    String res = await AuthMethod().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "success") {
      await storage.delete(key: 'email');
      await storage.delete(key: 'password');

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
        return CustomDialog(
          title: "Lupa sandi?",
          content: Column(
            children: [
              CustomTextField(
                controller: forgotEmailController,
                hintText: "Masukkan email",
                prefixIcon: const Icon(Icons.alternate_email),
              ),
              const SizedBox(height: 20),
              CustomButton(
                onTap: () async {
                  try {
                    await auth.sendPasswordResetEmail(
                        email: forgotEmailController.text);
                    if (!mounted) return;
                    showSnackBar(context,
                        "Kami sudah mengirimkan tautan untuk mereset sandi anda");
                    Navigator.pop(context);
                    forgotEmailController.clear();
                  } catch (e) {
                    showSnackBar(
                        context, "Terjadi kesalahan saat mengirim email reset");
                  }
                },
                text: 'Kirim Tautan Reset',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onClose: () => Navigator.pop(context),
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
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Aplikasi Monitoring Tambak",
                    style: AppStyles.titleStyle,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'images/udang.png',
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: tambakIdController,
                    hintText: 'Masukkan ID Tambak',
                    prefixIcon: const Icon(Icons.qr_code_2),
                    errorText: tambakIdError,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Masukkan email',
                    prefixIcon: const Icon(Icons.alternate_email),
                    errorText: emailError,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Masukkan sandi',
                    prefixIcon: const Icon(Icons.lock),
                    errorText: passwordError,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    onTap: loginUser,
                    text: 'MASUK',
                    isLoading: isLoading,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GoogleSignInButton(
                    onTap: () async {
                      if (tambakIdController.text.isEmpty) {
                        showSnackBar(context, "ID Tambak tidak boleh kosong");
                        return;
                      }
                      if (tambakIdController.text != '002543') {
                        showSnackBar(context, "ID Tambak tidak valid");
                        return;
                      }

                      try {
                        bool loginSuccess =
                            await FirebaseServices().signInWithGoogle();

                        if (loginSuccess) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', true);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHomePage(
                                title: 'Monitoring Tambak Udang',
                              ),
                            ),
                          );
                        }
                      } catch (error) {
                        showSnackBar(
                            context, "Login dibatalkan atau terjadi kesalahan");
                      }
                    },
                  ),
                  const SizedBox(height: 20),
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
      ),
    );
  }
}
