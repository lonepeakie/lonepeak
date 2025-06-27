import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final membersServiceProvider = Provider<MembersService>(
  (ref) => MembersService(),
);

class MembersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('MembersService'));

  CollectionReference<Member> _getMembersCollection(String estateId) {
    return _db
        .collection('estates')
        .doc(estateId)
        .collection('members')
        .withConverter(
          fromFirestore: Member.fromFirestore,
          toFirestore: (Member member, options) => member.toFirestore(),
        );
  }

  Future<Result<void>> addMember(String estateId, Member member) async {
    final docRef = _getMembersCollection(estateId).doc(member.email);

    try {
      await docRef.set(member);
      _log.i('Member added successfully with ID: ${member.email}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error adding member: $e');
      return Result.failure('Failed to add member');
    }
  }

  Future<Result<Member>> getMemberById(String estateId, String email) async {
    final docRef = _getMembersCollection(estateId).doc(email);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return Result.success(snapshot.data());
      } else {
        return Result.failure('Member not found');
      }
    } catch (e) {
      _log.e('Error getting member: $e');
      return Result.failure('Failed to get member');
    }
  }

  Future<Result<List<Member>>> getMembers(String estateId) async {
    final collectionRef = _getMembersCollection(estateId);

    try {
      final snapshot = await collectionRef.get();
      final members = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(members);
    } catch (e) {
      _log.e('Error getting members: $e');
      return Result.failure('Failed to get members');
    }
  }

  Future<Result<List<Member>>> getMembersByRoles(
    String estateId,
    List<String> roles,
  ) async {
    final collectionRef = _getMembersCollection(estateId);

    try {
      final snapshot = await collectionRef.where('role', whereIn: roles).get();
      final members = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(members);
    } catch (e) {
      _log.e('Error getting members by roles: $e');
      return Result.failure('Failed to get members by roles');
    }
  }

  Future<Result<int>> getMemberCount(String estateId) async {
    final collectionRef = _getMembersCollection(estateId);

    try {
      final res = await collectionRef.count().get();
      return Result.success(res.count);
    } catch (error) {
      _log.e('Error getting member count: $error');
      return Result.failure('Failed to get member count');
    }
  }

  Future<Result<void>> updateMember(String estateId, Member member) async {
    final docRef = _getMembersCollection(estateId).doc(member.email);

    try {
      await docRef.update(member.toFirestore());
      _log.i('Member updated successfully with ID: ${member.email}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating member: $e');
      return Result.failure('Failed to update member');
    }
  }

  Future<Result<void>> deleteMember(String estateId, String memberId) async {
    final docRef = _getMembersCollection(estateId).doc(memberId);

    try {
      await docRef.delete();
      _log.i('Member deleted successfully with ID: $memberId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error deleting member: $e');
      return Result.failure('Failed to delete member');
    }
  }
}
