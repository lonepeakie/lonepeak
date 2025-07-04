import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_credentials.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, UIState>((
  ref,
) {
  final userSiginFeature = ref.watch(userSiginFeatureProvider);
  return LoginViewModel(userSiginFeature: userSiginFeature);
});

class LoginViewModel extends StateNotifier<UIState> {
  LoginViewModel({required UserSiginFeature userSiginFeature})
    : _userSiginFeature = userSiginFeature,
      super(UIStateInitial());

  final UserSiginFeature _userSiginFeature;
  final _log = Logger(printer: PrefixedLogPrinter('SignInViewModel'));

  Future<bool> logIn() async {
    state = UIStateLoading();

    final result = await _userSiginFeature.logInAndAddUserIfNotExists(
      AuthType.google,
    );
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

  Future<bool> signInWithEmail(String email, String password) async {
    state = UIStateLoading();

    final credentials = EmailCredentials(
      email: email,
      password: password,
      isSignUp: false,
    );

    final result = await _userSiginFeature.logInAndAddUserIfNotExists(
      AuthType.email,
      credentials: credentials,
    );

    if (result.isSuccess) {
      _log.i('Email sign-in successful: ${result.data}');
      state = UIStateSuccess();
      return true;
    } else {
      _log.e('Email sign-in failed: ${result.error}');
      state = UIStateFailure(result.error ?? 'Unknown error');
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    state = UIStateLoading();

    final credentials = EmailCredentials(
      email: email,
      password: password,
      isSignUp: true,
    );

    final result = await _userSiginFeature.logInAndAddUserIfNotExists(
      AuthType.email,
      credentials: credentials,
    );

    if (result.isSuccess) {
      _log.i('Email sign-up successful: ${result.data}');
      state = UIStateSuccess();
      return true;
    } else {
      _log.e('Email sign-up failed: ${result.error}');
      state = UIStateFailure(result.error ?? 'Unknown error');
      return false;
    }
  }

  Future<bool> logOut() async {
    state = UIStateLoading();

    final result = await _userSiginFeature.logOut();
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
