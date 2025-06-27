import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, UIState>((
  ref,
) {
  final userSiginFeature = ref.watch(userSiginFeatureProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginViewModel(
    userSiginFeature: userSiginFeature,
    authRepository: authRepository,
  );
});

class LoginViewModel extends StateNotifier<UIState> {
  LoginViewModel({
    required UserSiginFeature userSiginFeature,
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       _userSiginFeature = userSiginFeature,
       super(UIStateInitial());

  final AuthRepository _authRepository;
  final UserSiginFeature _userSiginFeature;
  final _log = Logger(printer: PrefixedLogPrinter('SignInViewModel'));

  Future<bool> logIn() async {
    state = UIStateLoading();

    final result = await _userSiginFeature.logInAndAddUserIfNotExists();
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
