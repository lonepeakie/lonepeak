import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/ui/signin/view_models/auth_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final signInViewModelProvider =
    StateNotifierProvider<SignInViewModel, AuthState>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return SignInViewModel(authRepository: authRepository);
    });

class SignInViewModel extends StateNotifier<AuthState> {
  SignInViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial());

  final AuthRepository _authRepository;
  final _log = Logger(printer: AppPrefixPrinter('SignInViewModel'));

  Future<void> signIn() async {
    state = AuthLoading();

    final authType = AuthType.google;

    final result = await _authRepository.signIn(authType);

    if (result.isSuccess) {
      _log.i('Successfully signed in with Google account');
      state = AuthSuccess();
    } else {
      _log.e('Error signing in: ${result.error}');
      state = AuthFailure();
    }
  }
}
