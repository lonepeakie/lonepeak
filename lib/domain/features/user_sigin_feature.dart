import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_credentials.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final userSiginFeatureProvider = Provider<UserSiginFeature>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final usersRepository = ref.read(usersRepositoryProvider);
  final appState = ref.read(appStateProvider);
  final authState = ref.read(authStateProvider);

  return UserSiginFeature(
    authRepository: authRepository,
    usersRepository: usersRepository,
    appState: appState,
    authState: authState,
  );
});

class UserSiginFeature {
  UserSiginFeature({
    required AuthRepository authRepository,
    required UsersRepository usersRepository,
    required AppState appState,
    required AuthState authState,
  }) : _authRepository = authRepository,
       _usersRepository = usersRepository,
       _appState = appState;

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final AppState _appState;

  final _log = Logger(printer: PrefixedLogPrinter('UserSiginFeature'));

  Future<Result<bool>> logInAndAddUserIfNotExists(
    AuthType authType, {
    AuthCredentials? credentials,
  }) async {
    Result result = await _authRepository.signIn(
      authType,
      credentials: credentials,
    );
    if (result.isFailure) {
      _log.e('Log-in failed: ${result.error}');
      return Result.failure(result.error ?? 'Log-in failed');
    }

    result = _authRepository.getCurrentUser();
    if (result.isFailure) {
      _log.e('Failed to get current user: ${result.error}');
      await _authRepository.signOut();
      return Result.failure(result.error ?? 'Failed to get current user');
    }

    final currentUser = result.data;
    if (currentUser == null) {
      _log.e('Current user is null after sign-in');
      await _authRepository.signOut();
      return Result.failure('Current user is null');
    }

    final storedUser = await _usersRepository.getUser(currentUser.email);
    if (storedUser.isFailure) {
      final user = currentUser.copyWith(
        email: currentUser.email,
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoUrl,
      );

      final addUserResult = await _usersRepository.addUser(user);
      if (addUserResult.isFailure) {
        _log.e('Failed to add user: ${addUserResult.error}');
        await _authRepository.signOut();
        return Result.failure(addUserResult.error ?? 'Failed to add user');
      }

      _log.i('User added successfully: ${user.email}');
    } else {
      _log.i('User already exists: ${currentUser.email}');
      if (storedUser.data!.estateId != null) {
        _appState.setEstateId(storedUser.data!.estateId!);
      }
    }

    return Result.success(false);
  }

  Future<Result<bool>> logOut() async {
    final result = await _authRepository.signOut();
    if (result.isFailure) {
      _log.e('Log-out failed: ${result.error}');
      return Result.failure(result.error ?? 'Log-out failed');
    }

    final clearEstateResult = await _appState.clearEstateId();
    if (clearEstateResult.isFailure) {
      _log.e('Failed to clear estate ID: ${clearEstateResult.error}');
      return Result.failure(
        clearEstateResult.error ?? 'Failed to clear estate ID',
      );
    }

    final clearRoleResult = await _appState.clearUserRole();
    if (clearRoleResult.isFailure) {
      _log.e('Failed to clear user role: ${clearRoleResult.error}');
      return Result.failure(
        clearRoleResult.error ?? 'Failed to clear user role',
      );
    }

    return Result.success(true);
  }
}
