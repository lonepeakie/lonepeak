import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/notice/notices_provider.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/utils/ui_state.dart';

final estateNoticesViewModelProvider =
    StateNotifierProvider<EstateNoticesViewmodel, UIState>(
      (ref) => EstateNoticesViewmodel(
        noticesRepository: ref.watch(noticesRepositoryProvider),
      ),
    );

class EstateNoticesViewmodel extends StateNotifier<UIState> {
  EstateNoticesViewmodel({required NoticesRepository noticesRepository})
    : _noticesRepository = noticesRepository,
      super(UIStateInitial());

  final NoticesRepository _noticesRepository;

  List<Notice> get notices => _notices;
  List<Notice> _notices = [];

  Future<void> getNotices() async {
    state = UIStateLoading();

    final result = await _noticesRepository.getNotices();
    if (result.isSuccess) {
      _notices = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }

  Future<void> addNotice(Notice notice) async {
    state = UIStateLoading();

    final result = await _noticesRepository.addNotice(notice);
    if (result.isSuccess) {
      _notices.add(notice);
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }

  Future<void> toggleLike(String noticeId) async {
    // Don't show loading state for likes to avoid UI flickering
    final result = await _noticesRepository.toggleLike(noticeId);

    if (result.isSuccess) {
      // Update the notice in our local list
      final updatedNotice = result.data!;
      final index = _notices.indexWhere((notice) => notice.id == noticeId);

      if (index != -1) {
        _notices[index] = updatedNotice;
        // Notify listeners without changing UI state
        state = UIStateSuccess();
      }
    }
  }
}
