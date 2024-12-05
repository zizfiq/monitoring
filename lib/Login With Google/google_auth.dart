import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      // Memastikan pengguna memilih akun setiap kali
      await googleSignIn.signOut(); // Keluar dari akun yang ada sebelumnya

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // Jika pengguna membatalkan login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Melakukan sign-in dengan kredensial yang didapat
      await auth.signInWithCredential(credential);

      // Simpan atau validasi informasi pengguna
      // Potensial untuk memeriksa terhadap whitelist atau database
    } catch (e) {
      print("Google Sign-In Error: $e");
      // Tangani kegagalan sign-in
    }
  }

  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }
}
