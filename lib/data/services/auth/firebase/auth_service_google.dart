import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/utils/log_printer.dart';

class AuthServiceGoogle {
  final _log = Logger(printer: PrefixedLogPrinter('AuthServiceGoogle'));
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signIn() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(
          authProvider,
        );

        user = userCredential.user;
      } catch (e) {
        _log.e('Error signing in with Google: $e');
        rethrow;
      }
    } else {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        _log.w('Google sign-in was aborted by the user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );
        user = userCredential.user;
        if (user == null) {
          _log.w('User credential is null after sign-in.');
        }
        _log.i('User signed in successfully with Google.');
      } catch (e) {
        _log.e('Error during Google sign-in: $e');
        rethrow;
      }
    }
    return user;
  }
}
