import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final authStateProvider = Provider<AuthState>((ref) {
  return AuthState(ref);
});

class AuthState extends ChangeNotifier {
  AuthState(this._ref) {
    _authRepository = _ref.read(authRepositoryProvider);
    _appState = _ref.read(appStateProvider);
    _checkAuthState();
  }

  final Ref _ref;
  late final AuthRepository _authRepository;
  late final AppState _appState;

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> _checkAuthState() async {
    final result = await _authRepository.isAuthenticated();
    if (result.isSuccess) {
      _isAuthenticated = result.data ?? false;
      _appState.setAppData();
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<void> refreshAuthState() async {
    await _checkAuthState();
  }
}
