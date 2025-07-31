enum AuthType {
  google('Google'),
  email('Email');

  final String name;

  const AuthType(this.name);

  static AuthType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'google':
        return AuthType.google;
      case 'email':
        return AuthType.email;
      default:
        throw ArgumentError('Unknown AuthType: $type');
    }
  }
}
