import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/utils/log_printer.dart';

class AuthServiceEmail {
  final _log = Logger(printer: PrefixedLogPrinter('AuthServiceEmail'));

  // Development-only email/password authentication methods
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!kDebugMode) {
      _log.w('Email/password authentication is only available in debug mode');
      return null;
    }

    try {
      _log.i('Attempting to sign in with email: $email');
      final UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      _log.i('Email sign in successful for user: ${result.user?.email}');
      return result.user;
    } catch (e, stackTrace) {
      _log.e('Error signing in with email: $e\nStackTrace: $stackTrace');
      return null;
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!kDebugMode) {
      _log.w('Email/password registration is only available in debug mode');
      return null;
    }

    try {
      _log.i('Attempting to create user with email: $email');
      final UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      _log.i('Email registration successful for user: ${result.user?.email}');
      return result.user;
    } catch (e, stackTrace) {
      _log.e('Error creating user with email: $e\nStackTrace: $stackTrace');
      return null;
    }
  }
}
