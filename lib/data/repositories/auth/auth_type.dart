enum AuthType {
  google,
  email;

  @override
  String toString() {
    return name;
  }

  static AuthType fromString(String value) {
    switch (value) {
      case 'google':
        return AuthType.google;
      case 'email':
        return AuthType.email;
      default:
        throw ArgumentError('Invalid auth type: $value');
    }
  }
}
