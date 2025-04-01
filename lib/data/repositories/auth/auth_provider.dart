import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/data/repositories/auth/auth_state.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_client.dart';

final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
      return AuthStateNotifier();
    });

final authRepositoryProvider = Provider<AuthRepositoryFirebase>((ref) {
  final authClient = AuthClient();
  final authStateNotifier = ref.watch(authStateNotifierProvider.notifier);
  return AuthRepositoryFirebase(
    authClient: authClient,
    authStateNotifier: authStateNotifier,
  );
});
