import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/ui/login/view_models/login_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return LoginViewModel(authRepository: authRepository);
    });

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(LoginStateInitial());

  final AuthRepository _authRepository;
  final _log = Logger(printer: PrefixedLogPrinter('SignInViewModel'));

  Future<bool> logIn() async {
    state = LoginStateLoading();

    try {
      final result = await _authRepository.signIn(AuthType.google);
      if (result.isSuccess) {
        _log.i('Log-in successful: ${result.data}');
        state = LoginStateSuccess();
        return true;
      } else {
        _log.e('Log-in failed: ${result.error}');
        state = LoginStateFailure(result.error ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      _log.e('Error during log-in: $e');
      state = LoginStateFailure("Error during sign-in, please try again.");
      return false;
    }
  }

  Future<bool> logOut() async {
    state = LoginStateLoading();

    try {
      final result = await _authRepository.signOut(AuthType.google);
      if (result) {
        _log.i('Log-out successful');
        state = LoginStateInitial();
        return true;
      } else {
        _log.e('Log-out failed');
        state = LoginStateFailure('Log-out failed');
        return false;
      }
    } catch (e) {
      _log.e('Error during log-out: $e');
      state = LoginStateFailure("Error during sign-out, please try again.");
      return false;
    }
  }
}
