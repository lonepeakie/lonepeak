import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final estateSelectViewModelProvider =
    StateNotifierProvider<EstateSelectViewmodel, UIState>((ref) {
      return EstateSelectViewmodel(
        usersRepository: ref.read(usersRepositoryProvider),
        appState: ref.read(appStateProvider),
      );
    });

class EstateSelectViewmodel extends StateNotifier<UIState> {
  EstateSelectViewmodel({
    required UsersRepository usersRepository,
    required AppState appState,
  }) : _usersRepository = usersRepository,
       _appState = appState,
       super(UIStateInitial());

  final UsersRepository _usersRepository;
  final AppState _appState;

  User get user => _user;
  User _user = User.empty();

  Future<void> loadUser() async {
    state = UIStateLoading();

    final userId = _appState.getUserId();
    if (userId == null) {
      state = UIStateFailure('User ID is null');
      return;
    }

    final result = await _usersRepository.getUser(userId);
    if (result.isFailure) {
      state = UIStateFailure(result.error ?? 'Unknown error');
      return;
    }

    if (result.data == null) {
      state = UIStateFailure('User not found');
      return;
    }
    _user = result.data ?? User.empty();
    state = UIStateSuccess();
  }
}
