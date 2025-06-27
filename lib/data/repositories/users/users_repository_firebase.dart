import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/services/users/users_service.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/utils/result.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryFirebase(usersService: ref.read(usersServiceProvider));
});

class UsersRepositoryFirebase extends UsersRepository {
  UsersRepositoryFirebase({required UsersService usersService})
    : _usersService = usersService;

  final UsersService _usersService;

  @override
  Future<Result<void>> addUser(User user) {
    final updatedUser = user.copyWith(
      metadata: Metadata(createdAt: Timestamp.now()),
    );
    return _usersService.addUser(updatedUser);
  }

  @override
  Future<Result<void>> deleteUser(String email) {
    return _usersService.deleteUser(email);
  }

  @override
  Future<Result<User>> getUser(String email) {
    return _usersService.getUser(email);
  }

  @override
  Future<Result<void>> updateUser(User user) {
    final updatedUser = user.copyWith(
      metadata: user.metadata?.copyWith(updatedAt: Timestamp.now()),
    );
    return _usersService.updateUser(user.email, updatedUser);
  }
}
