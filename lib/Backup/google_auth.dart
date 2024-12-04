/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Additional validation can be added here
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      // Store or validate user information
      // Potentially check against a whitelist or database
    } catch (e) {
      print("Google Sign-In Error: $e");
      // Handle sign-in failure
    }
  }

  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }
}
*/