import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final noticeServiceProvider = Provider<NoticeService>((ref) => NoticeService());

class NoticeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('NoticeService'));

  Future<Result<void>> createNotice(String estateId, Notice noticeData) async {
    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('notices')
        .withConverter(
          fromFirestore: Notice.fromFirestore,
          toFirestore: (Notice notice, options) => notice.toFirestore(),
        )
        .doc(noticeData.id);

    try {
      await docRef.set(noticeData);
      _log.i('Notice created successfully with ID: ${noticeData.id}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error creating notice: $e');
      return Result.failure('Failed to create notice');
    }
  }

  Future<Result<Notice>> getNotice(String estateId, String noticeId) async {
    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('notices')
        .withConverter(
          fromFirestore: Notice.fromFirestore,
          toFirestore: (Notice notice, options) => notice.toFirestore(),
        )
        .doc(noticeId);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return Result.success(snapshot.data()!);
      } else {
        return Result.failure('Notice not found');
      }
    } catch (e) {
      _log.e('Error fetching notice: $e');
      return Result.failure('Failed to fetch notice');
    }
  }

  Future<Result<void>> updateNotice(String estateId, Notice noticeData) async {
    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('notices')
        .withConverter(
          fromFirestore: Notice.fromFirestore,
          toFirestore: (Notice notice, options) => notice.toFirestore(),
        )
        .doc(noticeData.id);

    try {
      await docRef.update(noticeData.toFirestore());
      _log.i('Notice updated successfully with ID: ${noticeData.id}');
      return Result.success(null);
    } catch (e) {
      _log.e('Error updating notice: $e');
      return Result.failure('Failed to update notice');
    }
  }

  Future<Result<void>> deleteNotice(String estateId, String noticeId) async {
    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('notices')
        .withConverter(
          fromFirestore: Notice.fromFirestore,
          toFirestore: (Notice notice, options) => notice.toFirestore(),
        )
        .doc(noticeId);

    try {
      await docRef.delete();
      _log.i('Notice deleted successfully with ID: $noticeId');
      return Result.success(null);
    } catch (e) {
      _log.e('Error deleting notice: $e');
      return Result.failure('Failed to delete notice');
    }
  }

  Future<Result<List<Notice>>> getNotices(String estateId) async {
    final collectionRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('notices')
        .withConverter(
          fromFirestore: Notice.fromFirestore,
          toFirestore: (Notice notice, options) => notice.toFirestore(),
        );

    try {
      final snapshot = await collectionRef.get();
      final notices = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(notices);
    } catch (e) {
      _log.e('Error fetching notices: $e');
      return Result.failure('Failed to fetch notices');
    }
  }
}
