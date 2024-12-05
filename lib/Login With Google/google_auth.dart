import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> signInWithGoogle() async {
    try {
      // Ensure the user selects an account each time
      await googleSignIn.signOut(); // Sign out from the previous account

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false; // User canceled the login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the obtained credentials
      await auth.signInWithCredential(credential);

      // Optionally, save or validate user information
      // Potentially check against a whitelist or database

      return true; // Sign-in successful
    } catch (e) {
      print("Google Sign-In Error: $e");
      // Handle sign-in failure
      return false; // Sign-in failed
    }
  }

  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }
}
