enum AuthType {
  google;

  @override
  String toString() {
    return name;
  }

  static AuthType fromString(String value) {
    switch (value) {
      case 'google':
        return AuthType.google;
      default:
        throw ArgumentError('Invalid auth type: $value');
    }
  }
}
