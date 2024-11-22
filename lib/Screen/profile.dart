import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _openInstagram(BuildContext context) async {
    const url = 'https://www.instagram.com/fiqri.aaziz/';
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // Handle the error gracefully
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not open Instagram. Please try again later.')),
      );
    }
  }

  Widget _buildProfileButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Background color
        elevation: 4, // Shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2), // Border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shadowColor: Colors.black, // Shadow color
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
        child: Padding(
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
                        child: Image.network(
                          'https://static.wikia.nocookie.net/gensin-impact/images/2/24/Raiden_Shogun_Icon.png/revision/latest?cb=20240717072843',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fiqri Abdul Aziz',
                      style: TextStyle(
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
                        'Administrator',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'fiqri@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileButton(
                text: 'Help & support',
                icon: Icons.help_outline_rounded,
                onTap: () => _openInstagram(context), // Open Instagram on tap
              ),
              const SizedBox(height: 16),
              _buildProfileButton(
                text: 'Send feedback',
                icon: Icons.feedback_outlined,
                onTap: () {
                  // Implement feedback functionality here
                },
              ),
              const SizedBox(height: 16),
              _buildProfileButton(
                text: 'Sign out',
                icon: Icons.logout_rounded,
                onTap: () {
                  // Implement sign out functionality here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
