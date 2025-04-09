import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/ui_state.dart';

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, UIState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginViewModel(authRepository: authRepository);
});

class LoginViewModel extends StateNotifier<UIState> {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(UIStateInitial());

  final AuthRepository _authRepository;
  final _log = Logger(printer: PrefixedLogPrinter('SignInViewModel'));

  Future<bool> logIn() async {
    state = UIStateLoading();

    final result = await _authRepository.signIn(AuthType.google);
    if (result.isSuccess) {
      _log.i('Log-in successful: ${result.data}');
      state = UIStateSuccess();
      return true;
    } else {
      _log.e('Log-in failed: ${result.error}');
      state = UIStateFailure(result.error ?? 'Unknown error');
      return false;
    }
  }

  Future<bool> logOut() async {
    state = UIStateLoading();

    final result = await _authRepository.signOut(AuthType.google);
    if (result.isSuccess) {
      _log.i('Log-out successful');
      state = UIStateInitial();
      return true;
    } else {
      _log.e('Log-out failed');
      state = UIStateFailure('Log-out failed');
      return false;
    }
  }
}
