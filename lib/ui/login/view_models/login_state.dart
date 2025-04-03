abstract class LoginState {}

class LoginStateInitial extends LoginState {}

class LoginStateLoading extends LoginState {}

class LoginStateSuccess extends LoginState {}

class LoginStateFailure extends LoginState {
  final String error;

  LoginStateFailure(this.error);

  @override
  String toString() => 'Login failure: $error';
}
