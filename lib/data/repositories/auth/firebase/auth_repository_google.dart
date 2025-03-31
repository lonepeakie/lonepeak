import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/utils/log_printer.dart';

class AuthRepositoryGoogle extends AuthRepository {
  final _log = Logger(printer: AppPrefixPrinter('AuthRepositoryGoogle'));
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<bool> isAuthenticated() {
    // TODO: implement isAuthenticated
    throw UnimplementedError();
  }

  @override
  Future<void> signIn(String email, String password) {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<bool> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e, stackTrace) {
      _log.e('Error signing out: $e\nStackTrace: $stackTrace');
      return false;
    }
  }
}
