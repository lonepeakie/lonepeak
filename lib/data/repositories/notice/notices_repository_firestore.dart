import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/data/services/notices/notices_service.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final noticesRepositoryProvider = Provider<NoticesRepository>((ref) {
  final noticesService = ref.read(noticesServiceProvider);
  final appState = ref.read(appStateProvider);

  return NoticesRepositoryFirestore(
    noticesService: noticesService,
    appState: appState,
  );
});

class NoticesRepositoryFirestore extends NoticesRepository {
  NoticesRepositoryFirestore({
    required NoticesService noticesService,
    required AppState appState,
  }) : _noticesService = noticesService,
       _appState = appState;

  final NoticesService _noticesService;
  final AppState _appState;

  @override
  Future<Result<void>> addNotice(Notice notice) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final updatedNotice = notice.copyWith(
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userEmail),
    );

    return _noticesService.createNotice(estateId, updatedNotice);
  }

  @override
  Future<Result<void>> deleteNotice(String id) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _noticesService.deleteNotice(estateId, id);
  }

  @override
  Future<Result<Notice>> getNoticeById(String id) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _noticesService.getNotice(estateId, id);
  }

  @override
  Future<Result<List<Notice>>> getNotices() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _noticesService.getNotices(estateId);
  }

  @override
  Future<Result<List<Notice>>> getLatestNotices({int limit = 2}) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    return _noticesService.getLatestNotices(estateId, limit);
  }

  @override
  Future<Result<void>> updateNotice(Notice notice) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final updatedNotice = notice.copyWith(
      metadata: notice.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userEmail,
      ),
    );
    return _noticesService.updateNotice(estateId, updatedNotice);
  }

  @override
  Future<Result<Notice>> toggleLike(String noticeId) async {
    final estateId = await _appState.getEstateId();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    if (userId == null) {
      return Result.failure('User ID is null');
    }

    return _noticesService.likeNotice(estateId, noticeId, userId);
  }
}
