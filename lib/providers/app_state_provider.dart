import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/users/users_provider.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';

final appStateProvider = Provider<AppState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final usersRepository = ref.watch(usersRepositoryProvider);
  return AppState(
    authRepository: authRepository,
    usersRepository: usersRepository,
  );
});

//TODO: Persist app state
class AppState {
  AppState({
    required AuthRepository authRepository,
    required UsersRepository usersRepository,
  }) : _authRepository = authRepository,
       _usersRepository = usersRepository;

  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;

  String? _estateId;
  String? _userEmail;

  Future<void> setEstateId(String estateId) async => _estateId = estateId;
  Future<void> setUserEmail(String userEmail) async => _userEmail = userEmail;

  String? get getEstateId => _estateId;
  String? get getUserEmail => _userEmail;

  Future<void> setUserAndEstateId() async {
    final authResult = await _authRepository.getCurrentUser();
    final currentUser = authResult.data;
    _userEmail = currentUser?.email;

    if (_userEmail == null) {
      return;
    }

    final storedUser = await _usersRepository.getUser(_userEmail!);
    if (storedUser.isFailure) {
      return;
    }

    _estateId = storedUser.data?.estateId;

    return;
  }
}
