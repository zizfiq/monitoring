import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Screen/login.dart';
import '../Widget/snackbar.dart';
import '../Widget/interface.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with RestorationMixin {
  // Restoration properties
  final RestorableTextEditingController _emailController =
      RestorableTextEditingController();
  final RestorableTextEditingController _passwordController =
      RestorableTextEditingController();
  final RestorableTextEditingController _nameController =
      RestorableTextEditingController();

  final RestorableBool _isLoading = RestorableBool(false);
  final RestorableBool _obscureText = RestorableBool(true);

  late final RestorableString _emailError = RestorableString('');
  late final RestorableString _passwordError = RestorableString('');
  late final RestorableString _nameError = RestorableString('');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  String? get restorationId => 'signup_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_emailController, 'email_controller');
    registerForRestoration(_passwordController, 'password_controller');
    registerForRestoration(_nameController, 'name_controller');
    registerForRestoration(_isLoading, 'is_loading');
    registerForRestoration(_obscureText, 'obscure_text');
    registerForRestoration(_emailError, 'email_error');
    registerForRestoration(_passwordError, 'password_error');
    registerForRestoration(_nameError, 'name_error');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _isLoading.dispose();
    _obscureText.dispose();
    _emailError.dispose();
    _passwordError.dispose();
    _nameError.dispose();
    super.dispose();
  }

  void _resetErrors() {
    setState(() {
      _emailError.value = '';
      _passwordError.value = '';
      _nameError.value = '';
    });
  }

  bool validateFields() {
    bool isValid = true;
    _resetErrors();

    // Validate name
    if (_nameController.value.text.trim().isEmpty) {
      _nameError.value = "Nama harus diisi";
      isValid = false;
    }

    // Validate Email
    if (_emailController.value.text.isEmpty) {
      _emailError.value = "Email harus diisi";
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.value.text)) {
      _emailError.value = "Format email tidak valid";
      isValid = false;
    }

    // Validate Password
    if (_passwordController.value.text.isEmpty) {
      _passwordError.value = "Kata sandi harus diisi";
      isValid = false;
    } else if (_passwordController.value.text.length < 6) {
      _passwordError.value = "Kata sandi minimal 6 karakter";
      isValid = false;
    }

    return isValid;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText.value = !_obscureText.value;
    });
  }

  void signupUser() async {
    if (!validateFields()) {
      return;
    }

    setState(() {
      _isLoading.value = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.value.text.trim(),
        password: _passwordController.value.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.value.text.trim(),
        'name': _nameController.value.text.trim(),
        'uid': userCredential.user!.uid,
      });

      await userCredential.user!.sendEmailVerification();

      if (!mounted) return;

      showSnackBar(context, "Periksa email anda untuk verifikasi");

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading.value = false;
        switch (e.code) {
          case 'email-already-in-use':
            _emailError.value = "Email sudah terdaftar";
            break;
          case 'invalid-email':
            _emailError.value = "Format email tidak valid";
            break;
          case 'weak-password':
            _passwordError.value = "Password terlalu lemah";
            break;
          default:
            if (mounted) {
              showSnackBar(context, "Terjadi kesalahan: ${e.message}");
            }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading.value = false;
      });
      if (mounted) {
        showSnackBar(context, "Terjadi kesalahan tak terduga");
      }
    }
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
                  style: AppStyles.titleStyle,
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'images/udang.png',
                  height: 120,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _nameController.value,
                  hintText: 'Masukkan nama',
                  prefixIcon: const Icon(Icons.person),
                  errorText: _nameError.value.isEmpty ? null : _nameError.value,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController.value,
                  hintText: 'Masukkan email',
                  prefixIcon: const Icon(Icons.alternate_email),
                  errorText:
                      _emailError.value.isEmpty ? null : _emailError.value,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController.value,
                  hintText: 'Masukkan sandi',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _passwordError.value.isEmpty
                      ? null
                      : _passwordError.value,
                  obscureText: _obscureText.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  onTap: signupUser,
                  text: 'DAFTAR',
                  isLoading: _isLoading.value,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Sudah punya akun? Masuk",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
