import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/services/users/users_service.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/utils/result.dart';

class UsersRepositoryFirebase extends UsersRepository {
  UsersRepositoryFirebase({required UsersService usersService})
      : _usersService = usersService;

  final UsersService _usersService;

  @override
  Future<Result<void>> addUser(User user) {
    return _usersService.addUser(user);
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
    return _usersService.updateUser(user.email, user);
  }
}
