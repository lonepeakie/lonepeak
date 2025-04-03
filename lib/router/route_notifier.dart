import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _authRepository = _ref.read(authRepositoryProvider);
    _checkAuthState();
  }

  final Ref _ref;
  late final AuthRepository _authRepository;

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> _checkAuthState() async {
    _isAuthenticated = await _authRepository.isAuthenticated(AuthType.google);
    notifyListeners();
  }

  void refreshAuthState() {
    _checkAuthState();
  }
}
