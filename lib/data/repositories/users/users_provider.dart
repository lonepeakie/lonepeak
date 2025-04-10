import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/data/services/users/users_service.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryFirebase(usersService: ref.read(usersServiceProvider));
});
