import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monitoring/Screen/about.dart';
import 'package:monitoring/Screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  String displayName = 'Admin Tambak';
  String email = '';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Menambahkan listener untuk perubahan status autentikasi
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // Pengguna tidak terautentikasi, arahkan ke halaman login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Memuat ulang informasi pengguna saat aplikasi kembali ke latar depan
      setState(() {});
    }
  }

  Future<User?> _getUserInfo() async {
    return FirebaseAuth.instance.currentUser;
  }

  void _launchUrl(String url, BuildContext context) {
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildProfileButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shadowColor: Colors.black,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<User?>(
          future: _getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading user info'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No user found'));
            } else {
              final user = snapshot.data!;
              displayName = user.displayName ?? 'Penjaga Tambak';
              email = user.email ?? 'No email';
              profileImageUrl = user.photoURL;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            spreadRadius: 0,
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: profileImageUrl != null
                                  ? Image.network(
                                      profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.grey,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Pengelola',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProfileButton(
                      text: 'Bantuan & Dukungan',
                      icon: Icons.help_outline_rounded,
                      onTap: () => _launchUrl(
                        'mailto:fiqri.aaziz@gmail.com?subject=Laporan%20Bug%20&%20Support&body=Tuliskan%20kendala%20anda%20disini.',
                        context,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileButton(
                      text: 'Kirim umpan balik',
                      icon: Icons.feedback_outlined,
                      onTap: () => _launchUrl(
                        'mailto:fiqri.aaziz@gmail.com?subject=Umpan%20Balik%20&%20Support&body=Tuliskan%20umpan%20balik%20anda%20disini.',
                        context,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileButton(
                      text: 'Tentang',
                      icon: Icons.info_outline_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileButton(
                      text: 'Keluar',
                      icon: Icons.logout_rounded,
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            content: const Text(
                              'Apakah Anda yakin ingin logout?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.black, width: 2),
                            ),
                            backgroundColor: Colors.white,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Tutup dialog tanpa logout
                                },
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Logout setelah konfirmasi
                                  Navigator.of(context).pop(); // Tutup dialog
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('isLoggedIn', false);
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
