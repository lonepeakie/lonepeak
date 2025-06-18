import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/data/services/notices/notices_service.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

class NoticesRepositoryFirestore extends NoticesRepository {
  NoticesRepositoryFirestore({
    required NoticesService noticesService,
    required AppState appState,
  })  : _noticesService = noticesService,
        _appState = appState;

  final NoticesService _noticesService;
  final AppState _appState;

  @override
  Future<Result<void>> addNotice(Notice notice) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    // Set metadata for new notice
    notice.metadata = Metadata(
      createdAt: Timestamp.now(),
      createdBy: _appState.getUserId() ?? 'Unknown',
      updatedAt: Timestamp.now(),
    );

    return _noticesService.createNotice(estateId, notice);
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
    return _noticesService.updateNotice(estateId, notice);
  }

  @override
  Future<Result<Notice>> toggleLike(String noticeId) async {
    final estateId = await _appState.getEstateId();
    final userEmail = _appState.getUserId();

    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    if (userEmail == null) {
      return Result.failure('User email is null');
    }

    return _noticesService.likeNotice(estateId, noticeId, userEmail);
  }
}
