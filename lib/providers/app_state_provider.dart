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
  }

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final FlutterSecureStorage _secureStorage;

  static const String _estateIdKey = 'estate_id';

  String? _estateId;

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
    return await setEstateId(null);
  }

  String? getUserId() {
    try {
      return _authRepository.getCurrentUser().data?.email;
    } catch (e) {
      return null;
    }
  }
}
