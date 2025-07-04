import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final noticesServiceProvider = Provider<NoticesService>(
  (ref) => NoticesService(),
);

class NoticesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('NoticeService'));

  CollectionReference<Notice> _getNoticesCollection(String estateId) {
    return _db
        .collection('estates')
        .doc(estateId)
        .collection('notices')
        .withConverter(
          fromFirestore: Notice.fromFirestore,
          toFirestore: (Notice notice, _) => notice.toFirestore(),
        );
  }

  Future<Result<void>> createNotice(String estateId, Notice noticeData) async {
    final docRef = _getNoticesCollection(estateId).doc(noticeData.id);
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
    final docRef = _getNoticesCollection(estateId).doc(noticeId);
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
    final docRef = _getNoticesCollection(estateId).doc(noticeData.id);
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
    final docRef = _getNoticesCollection(estateId).doc(noticeId);
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
    final collectionRef = _getNoticesCollection(
      estateId,
    ).orderBy('metadata.createdAt', descending: true);
    try {
      final snapshot = await collectionRef.get();
      final notices = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(notices);
    } catch (e) {
      _log.e('Error fetching notices: $e');
      return Result.failure('Failed to fetch notices');
    }
  }

  Future<Result<List<Notice>>> getLatestNotices(
    String estateId,
    int limit,
  ) async {
    final collectionRef = _getNoticesCollection(
      estateId,
    ).orderBy('metadata.createdAt', descending: true).limit(limit);
    try {
      final snapshot = await collectionRef.get();
      final notices = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(notices);
    } catch (e) {
      _log.e('Error fetching latest notices: $e');
      return Result.failure('Failed to fetch latest notices');
    }
  }

  Future<Result<Notice>> likeNotice(
    String estateId,
    String noticeId,
    String userEmail,
  ) async {
    try {
      final noticeResult = await getNotice(estateId, noticeId);
      if (noticeResult.isFailure) {
        return Result.failure('Failed to fetch notice for liking');
      }

      final notice = noticeResult.data!;
      final likedBy = List<String>.from(notice.likedBy);

      if (likedBy.contains(userEmail)) {
        likedBy.remove(userEmail);
      } else {
        likedBy.add(userEmail);
      }

      final updatedNotice = notice.copyWith(likedBy: likedBy);
      final updateResult = await updateNotice(estateId, updatedNotice);

      if (updateResult.isFailure) {
        return Result.failure('Failed to update like status');
      }

      return Result.success(updatedNotice);
    } catch (e) {
      _log.e('Error toggling like: $e');
      return Result.failure('Failed to process like operation');
    }
  }

  Future<Result<List<Notice>>> getNoticesByType(
    String estateId,
    NoticeType type,
  ) async {
    try {
      final snapshot =
          await _getNoticesCollection(estateId)
              .where('type', isEqualTo: type.name)
              .orderBy('metadata.createdAt', descending: true)
              .get();
      final notices = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(notices);
    } catch (e) {
      _log.e('Error fetching notices by type: $e');
      return Result.failure('Failed to fetch notices by type');
    }
  }
}
