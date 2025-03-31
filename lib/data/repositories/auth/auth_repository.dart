abstract class AuthRepository {
  /// Returns true if the user is authenticated.
  Future<bool> isAuthenticated();

  /// Returns the current user.
  // Future<User?> getCurrentUser();

  /// Signs in the user with the given credentials.
  Future<void> signIn(String email, String password);

  /// Signs out the current user.
  Future<bool> signOut();
}
