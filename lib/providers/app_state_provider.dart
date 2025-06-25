import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/users/users_provider.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/utils/result.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final appStateProvider = Provider<AppState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final usersRepository = ref.read(usersRepositoryProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return AppState(
    authRepository: authRepository,
    usersRepository: usersRepository,
    secureStorage: secureStorage,
  );
});

class AppState {
  AppState({
    required AuthRepository authRepository,
    required UsersRepository usersRepository,
    required FlutterSecureStorage secureStorage,
  }) : _authRepository = authRepository,
       _usersRepository = usersRepository,
       _secureStorage = secureStorage {
    _loadEstateId();
    loadUserRole();
  }

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final FlutterSecureStorage _secureStorage;

  static const String _estateIdKey = 'estate_id';
  static const String _userRoleKey = 'user_role';

  String? _estateId;
  String? _userRole;

  Future<String?> getEstateId() async {
    if (_estateId != null) return _estateId;
    return _loadEstateId();
  }

  Future<String?> _loadEstateId() async {
    try {
      _estateId = await _secureStorage.read(key: _estateIdKey);
      return _estateId;
    } catch (e) {
      return null;
    }
  }

  Future<Result<void>> setEstateId(String? estateId) async {
    if (estateId == null) {
      final authResult = _authRepository.getCurrentUser();
      if (authResult.isFailure) {
        return Result.failure('Failed to get current user');
      }
      final currentUser = authResult.data;

      final storedUser = await _usersRepository.getUser(currentUser!.email);
      if (storedUser.isFailure) {
        return Result.failure('Failed to get user');
      }

      _estateId = storedUser.data?.estateId;
    } else {
      _estateId = estateId;
    }

    if (_estateId == null) {
      return Result.failure('Estate ID is null');
    }

    try {
      await _secureStorage.write(key: _estateIdKey, value: _estateId);
    } catch (e) {
      return Result.failure('Failed to save estate ID: $e');
    }

    return Result.success(null);
  }

  Future<Result<void>> clearEstateId() async {
    _estateId = null;
    try {
      await _secureStorage.delete(key: _estateIdKey);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear estate ID: $e');
    }
  }

  Future<Result<void>> setAppData() async {
    final estateIdResult = await setEstateId(null);
    if (estateIdResult.isFailure) {
      return estateIdResult;
    }
    return await clearUserRole();
  }

  String? getUserId() {
    try {
      return _authRepository.getCurrentUser().data?.email;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserRole() async {
    if (_userRole != null) return _userRole;
    return loadUserRole();
  }

  Future<Result<void>> setUserRole(String role) async {
    _userRole = role;
    try {
      await _secureStorage.write(key: _userRoleKey, value: role);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to save user role: $e');
    }
  }

  Future<String?> loadUserRole() async {
    try {
      _userRole = await _secureStorage.read(key: _userRoleKey);
      return _userRole;
    } catch (e) {
      return null;
    }
  }

  Future<Result<void>> clearUserRole() async {
    _userRole = null;
    try {
      await _secureStorage.delete(key: _userRoleKey);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to clear user role: $e');
    }
  }
}

final currentEstateIdProvider = FutureProvider<String?>((ref) {
  final appState = ref.watch(appStateProvider);
  return appState.getEstateId();
});
