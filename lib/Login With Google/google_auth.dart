import 'package:firebase_auth/firebase_auth.dart'; // ignore_for_file: avoid_print
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      // Disconnect any existing session
      await googleSignIn.disconnect();

      // Prompt the user to select an account
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await auth.signInWithCredential(authCredential);
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    } catch (e) {
      print("Error: $e");
    }
  }

  // Sign out from Google
  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }
}
