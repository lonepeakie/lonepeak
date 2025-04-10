import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final usersServiceProvider = Provider<UsersService>((ref) => UsersService());

class UsersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('UsersService'));

  Future<Result<void>> addUser(user) async {
    final docRef = _db
        .collection('users')
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, options) => user.toFirestore(),
        )
        .doc(user.email);

    try {
      await docRef.set(user);
      _log.i('User added successfully with ID: ${user.email}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error adding user: $e');
      return Result.failure('Failed to add user');
    }
  }

  Future<Result<User>> getUser(String email) async {
    final docRef = _db
        .collection('users')
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, options) => user.toFirestore(),
        )
        .doc(email);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return Result.success(snapshot.data());
      } else {
        return Result.failure('User not found');
      }
    } catch (e) {
      _log.e('Error getting user: $e');
      return Result.failure('Failed to get user');
    }
  }

  Future<Result<void>> updateUser(String email, User user) async {
    final docRef = _db
        .collection('users')
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, options) => user.toFirestore(),
        )
        .doc(email);

    try {
      await docRef.update(user.toFirestore());
      _log.i('User updated successfully with ID: ${user.email}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating user: $e');
      return Result.failure('Failed to update user');
    }
  }

  Future<Result<void>> deleteUser(String email) async {
    final docRef = _db
        .collection('users')
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (User user, options) => user.toFirestore(),
        )
        .doc(email);

    try {
      await docRef.delete();
      _log.i('User deleted successfully with ID: $email');
      return Result.success(null);
    } catch (e) {
      _log.e('Error deleting user: $e');
      return Result.failure('Failed to delete user');
    }
  }
}
