import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/utils/log_printer.dart';
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
    initAppData();
  }

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final FlutterSecureStorage _secureStorage;
  final _log = Logger(printer: PrefixedLogPrinter('AuthRepositoryFirebase'));

  static const String _estateIdKey = 'estate_id';

  String? _estateId;

  Future<String?> getEstateId() async {
    if (_estateId != null) return _estateId;

    return _loadEstateId();
  }

  Future<Result<void>> setEstateId(String estateId) async {
    _estateId = estateId;

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

  String? getUserId() {
    try {
      return _authRepository.getCurrentUser().data?.email;
    } catch (e) {
      return null;
    }
  }

  Future<Result<void>> initAppData() async {
    final estateId = await getEstateId();
    if (estateId == null || estateId.isEmpty) {
      return Result.failure('Estate ID is not set');
    }

    return Result.success(null);
  }

  Future<void> clearAppData() async {
    await clearEstateId();
  }

  Future<String?> _loadEstateId() async {
    try {
      final storedEstateId = await _secureStorage.read(key: _estateIdKey);

      if (storedEstateId != null && storedEstateId.isNotEmpty) {
        _estateId = storedEstateId;
        return _estateId;
      }

      _log.d('Estate ID not found in storage, fetching from user data');

      final fetchedEstateId = await _getEstateIdForLoggedInUser();

      if (fetchedEstateId == null || fetchedEstateId.isEmpty) {
        _log.w('No estate ID found for logged-in user');
        _estateId = null;
        return null;
      }

      _log.d('Saving fetched estate ID to storage: $fetchedEstateId');
      await _secureStorage.write(key: _estateIdKey, value: fetchedEstateId);
      _estateId = fetchedEstateId;

      return _estateId;
    } catch (e) {
      _log.e('Failed to load estate ID: $e');
      _estateId = null;
      return null;
    }
  }

  Future<String?> _getEstateIdForLoggedInUser() async {
    final authResult = _authRepository.getCurrentUser();
    if (authResult.isFailure) {
      _log.e('Failed to get current user: ${authResult.error}');
      throw Exception('Failed to get current user: ${authResult.error}');
    }

    final currentUser = authResult.data;
    if (currentUser?.email == null) {
      _log.e('Current user has no email');
      throw Exception('Current user has no email');
    }

    final userResult = await _usersRepository.getUser(currentUser!.email);
    if (userResult.isFailure) {
      _log.e(
        'Failed to get user data for ${currentUser.email}: ${userResult.error}',
      );
      throw Exception('Failed to get user data: ${userResult.error}');
    }

    final userData = userResult.data;
    _log.d('Fetched user data for: ${userData?.email}');

    final estateId = userData?.estateId;
    if (estateId == null || estateId.isEmpty) {
      _log.w('No estate ID found for user: ${userData?.email}');
      return null;
    }

    return estateId;
  }
}
