// lib/data/repositories/auth/auth_repository.dart

import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/utils/result.dart';

abstract class AuthRepository {
  Future<Result<bool>> isAuthenticated();
  Future<Result<User>> signIn(AuthType authType);
  Future<Result<void>> signOut(AuthType authType);
  Result<User> getCurrentUser();

  // FIX: Added method signatures for profile management.
  Future<Result<User>> updateProfile(String displayName, String email);
  Future<Result<User>> refreshUserData();
}
