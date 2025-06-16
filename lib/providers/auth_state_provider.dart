// lib/providers/auth_state_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final authStateProvider = ChangeNotifierProvider<AuthState>((ref) {
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
  final _log = Logger(printer: PrefixedLogPrinter('AuthState'));

  bool _isAuthenticated = false;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;

  Future<void> _checkAuthState() async {
    final result = await _authRepository.isAuthenticated();
    if (result.isSuccess) {
      _isAuthenticated = result.data ?? false;
      if (_isAuthenticated) {
        await _loadCurrentUser();
      }
      _appState.setAppData();
    } else {
      _isAuthenticated = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    final userResult = _authRepository.getCurrentUser();
    if (userResult.isSuccess) {
      _currentUser = userResult.data;
    }
  }

  // NOTE: This method now correctly calls the implemented repository method.
  Future<Result<User>> updateProfile(String displayName, String email) async {
    final result = await _authRepository.updateProfile(displayName, email);
    if (result.isSuccess) {
      _currentUser = result.data;
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    await _authRepository.signOut(AuthType.google);
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshAuthState() async {
    await _checkAuthState();
  }

  // NOTE: This method now correctly calls the implemented repository method.
  Future<void> refreshUserData() async {
    final result = await _authRepository.refreshUserData();
    if (result.isSuccess) {
      _currentUser = result.data;
      if (!_isAuthenticated) {
        _isAuthenticated = true;
      }
    } else {
      _log.w(
          "Failed to refresh user data. Session might be invalid. Forcing local logout.");
      _isAuthenticated = false;
      _currentUser = null;
    }
    notifyListeners();
  }
}
