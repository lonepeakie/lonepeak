import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/user.dart';

class UserProfileScreenArgs {
  final User user;
  final Estate estate;

  UserProfileScreenArgs({required this.user, required this.estate});
}
