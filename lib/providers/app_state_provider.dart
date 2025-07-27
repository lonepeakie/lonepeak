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
    _loadEstateId();
    _loadUserRole();
  }

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final FlutterSecureStorage _secureStorage;
  final _log = Logger(printer: PrefixedLogPrinter('AuthRepositoryFirebase'));

  static const String _estateIdKey = 'estate_id';
  static const String _userRoleKey = 'user_role';

  String? _estateId;
  String? _userRole;

  Future<String?> getEstateId() async {
    if (_estateId != null) return _estateId;

    await _loadEstateId();
    return _estateId;
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

  Future<String?> getUserRole() async {
    if (_userRole != null) return _userRole;

    return _loadUserRole();
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

  Future<String?> _loadUserRole() async {
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

  Future<Result<void>> _loadEstateId() async {
    if (await _secureStorage.containsKey(key: _estateIdKey)) {
      _log.d('Estate ID found in secure storage');
      _estateId = await _secureStorage.read(key: _estateIdKey);
      return Result.success(null);
    }

    final estateId = await _getEstateIdForLoggedInUser();
    _log.d('Estate ID for logged-in user: $estateId');
    if (estateId == null) {
      return Result.failure('No estate ID found for the logged-in user');
    }

    await setEstateId(estateId);
    return Result.success(null);
  }

  Future<String?> _getEstateIdForLoggedInUser() async {
    final authResult = _authRepository.getCurrentUser();
    if (authResult.isFailure) {
      throw Exception('Failed to get current user');
    }
    final currentUser = authResult.data;

    final storedUser = await _usersRepository.getUser(currentUser!.email);
    if (storedUser.isFailure) {
      throw Exception('Failed to get user');
    }

    _log.d('Fetched user: ${storedUser.data?.email}');
    if (storedUser.data?.estateId == null ||
        storedUser.data!.estateId!.isEmpty) {
      _log.w('No estate ID found for user: ${storedUser.data?.email}');
      return null;
    }
    return storedUser.data?.estateId;
  }

  Future<Result<void>> initAppData() async {
    final estateId = await getEstateId();
    if (estateId == null || estateId.isEmpty) {
      return Result.failure('Estate ID is not set');
    }

    return await clearUserRole();
  }
}
