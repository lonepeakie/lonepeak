import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/utils/result.dart';

abstract class NoticesRepository {
  Future<Result<List<Notice>>> getNotices();
  Future<Result<List<Notice>>> getLatestNotices({int limit = 2});
  Future<Result<Notice>> getNoticeById(String id);
  Future<Result<void>> addNotice(Notice notice);
  Future<Result<void>> updateNotice(Notice notice);
  Future<Result<void>> deleteNotice(String id);
  Future<Result<Notice>> toggleLike(String noticeId);
  Future<Result<List<Notice>>> getNoticesByType(NoticeType type);
}
