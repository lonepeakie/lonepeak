import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepositoryFirebase>((ref) {
  return AuthRepositoryFirebase(authService: ref.read(authServiceProvider));
});
