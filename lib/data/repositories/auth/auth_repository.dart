import 'package:lonepeak/data/repositories/auth/app_user.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/data/repositories/result.dart';

abstract class AuthRepository {
  /// Returns true if the user is authenticated.
  Future<bool> isAuthenticated(AuthType authType);

  /// Returns the current user.
  // Future<User?> getCurrentUser();

  /// Signs in the user with the given credentials.
  Future<Result<AppUser>> signIn(AuthType authType);

  /// Signs out the current user.
  Future<bool> signOut(AuthType authType);
}
