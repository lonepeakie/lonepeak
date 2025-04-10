import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/utils/result.dart';

abstract class UsersRepository {
  Future<Result<User>> getUser(String email);
  Future<Result<void>> addUser(User user);
  Future<Result<void>> updateUser(User user);
  Future<Result<void>> deleteUser(String email);
}
