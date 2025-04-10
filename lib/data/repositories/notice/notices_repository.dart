import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/utils/result.dart';

abstract class NoticesRepository {
  Future<Result<List<Notice>>> getNotices();
  Future<Result<Notice>> getNoticeById(String id);
  Future<Result<void>> addNotice(Notice notice);
  Future<Result<void>> updateNotice(Notice notice);
  Future<Result<void>> deleteNotice(String id);
}
