import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/domain/models/notice.dart';

final noticesByTypeProvider = FutureProvider.family
    .autoDispose<List<Notice>, NoticeType>((ref, type) async {
      final repo = ref.watch(noticesRepositoryProvider);
      final result = await repo.getNoticesByType(type);

      if (result.isSuccess) {
        return result.data!;
      } else {
        throw Exception(result.error);
      }
    });
