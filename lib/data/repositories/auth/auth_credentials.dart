abstract class AuthCredentials {
  const AuthCredentials();
}

class EmailCredentials extends AuthCredentials {
  final String email;
  final String password;
  final bool isSignUp;

  const EmailCredentials({
    required this.email,
    required this.password,
    this.isSignUp = false,
  });
}

class GoogleCredentials extends AuthCredentials {
  const GoogleCredentials();
}
