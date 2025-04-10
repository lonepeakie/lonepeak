import 'package:lonepeak/data/repositories/notice/notice_repository.dart';
import 'package:lonepeak/data/services/notice/notice_service.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

class NoticeRepositoryFirestore extends NoticeRepository {
  NoticeRepositoryFirestore({
    required NoticeService noticeService,
    required AppState appState,
  }) : _noticeService = noticeService,
       _appState = appState;

  final NoticeService _noticeService;
  final AppState _appState;

  @override
  Future<Result<void>> addNotice(Notice notice) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _noticeService.createNotice(estateId, notice);
  }

  @override
  Future<Result<void>> deleteNotice(String id) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _noticeService.deleteNotice(estateId, id);
  }

  @override
  Future<Result<Notice>> getNoticeById(String id) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _noticeService.getNotice(estateId, id);
  }

  @override
  Future<Result<List<Notice>>> getNotices() {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _noticeService.getNotices(estateId);
  }

  @override
  Future<Result<void>> updateNotice(Notice notice) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _noticeService.updateNotice(estateId, notice);
  }
}
