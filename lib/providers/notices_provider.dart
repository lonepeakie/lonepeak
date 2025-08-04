import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/utils/log_printer.dart';

final noticesProvider =
    StateNotifierProvider<NoticesProvider, AsyncValue<List<Notice>>>((ref) {
      final repository = ref.watch(noticesRepositoryProvider);
      return NoticesProvider(repository);
    });

final latestNoticesProvider = FutureProvider<List<Notice>>((ref) async {
  final repository = ref.watch(noticesRepositoryProvider);
  final result = await repository.getLatestNotices();

  if (result.isFailure) {
    throw Exception('Failed to fetch latest notices: ${result.error}');
  }

  return result.data ?? [];
});

class NoticesProvider extends StateNotifier<AsyncValue<List<Notice>>> {
  NoticesProvider(this._repository) : super(const AsyncValue.loading()) {
    _loadNotices();
  }

  final NoticesRepository _repository;
  final _log = Logger(printer: PrefixedLogPrinter('NoticesProvider'));

  Future<void> _loadNotices() async {
    await getNotices();
  }

  void ensureNoticesLoaded() {
    if (state is! AsyncLoading &&
        (!state.hasValue || state.value?.isEmpty == true)) {
      _loadNotices();
    }
  }

  List<Notice> get cachedNotices => state.value ?? [];

  Future<void> getNotices() async {
    if (state.hasValue &&
        state.value?.isNotEmpty == true &&
        state is! AsyncError) {
      return;
    }

    if (state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }

    try {
      _log.i('Fetching notices');
      final result = await _repository.getNotices();

      if (result.isFailure) {
        _log.e('Failed to fetch notices: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to fetch notices: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      final notices = result.data ?? [];
      _log.i('Successfully fetched ${notices.length} notices');
      state = AsyncValue.data(notices);
    } catch (error, stackTrace) {
      _log.e(
        'Error fetching notices: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addNotice(Notice notice) async {
    try {
      _log.i('Adding new notice: ${notice.title}');
      final result = await _repository.addNotice(notice);

      if (result.isFailure) {
        _log.e('Failed to create notice: ${result.error}');
        throw Exception('Failed to create notice: ${result.error}');
      }

      _log.i('Successfully added notice: ${notice.title}');
      await refreshNotices();
    } catch (error) {
      _log.e('Error adding notice: $error');
      rethrow;
    }
  }

  Future<void> toggleLike(String noticeId) async {
    try {
      _log.i('Toggling like for notice: $noticeId');
      final result = await _repository.toggleLike(noticeId);

      if (result.isFailure) {
        _log.e('Failed to toggle like: ${result.error}');
        throw Exception('Failed to toggle like: ${result.error}');
      }

      final updatedNotice = result.data!;
      final currentNotices = state.value ?? [];
      final index = currentNotices.indexWhere(
        (notice) => notice.id == noticeId,
      );

      if (index != -1) {
        final updatedNotices = [...currentNotices];
        updatedNotices[index] = updatedNotice;
        _log.i('Successfully toggled like for notice: $noticeId');
        state = AsyncValue.data(updatedNotices);
      }
    } catch (error) {
      _log.e('Error toggling like: $error');
    }
  }

  Future<void> updateNotice(Notice notice) async {
    try {
      _log.i('Updating notice: ${notice.title}');
      final result = await _repository.updateNotice(notice);

      if (result.isFailure) {
        _log.e('Failed to update notice: ${result.error}');
        throw Exception('Failed to update notice: ${result.error}');
      }

      final currentNotices = state.value ?? [];
      final index = currentNotices.indexWhere((n) => n.id == notice.id);
      if (index != -1) {
        final updatedNotices = [...currentNotices];
        updatedNotices[index] = notice;
        _log.i('Successfully updated notice: ${notice.title}');
        state = AsyncValue.data(updatedNotices);
      }
    } catch (error) {
      _log.e('Error updating notice: $error');
      rethrow;
    }
  }

  Future<void> deleteNotice(String noticeId) async {
    try {
      _log.i('Deleting notice: $noticeId');
      final result = await _repository.deleteNotice(noticeId);

      if (result.isFailure) {
        _log.e('Failed to delete notice: ${result.error}');
        throw Exception('Failed to delete notice: ${result.error}');
      }

      final currentNotices = state.value ?? [];
      final updatedNotices =
          currentNotices.where((notice) => notice.id != noticeId).toList();
      _log.i('Successfully deleted notice: $noticeId');
      state = AsyncValue.data(updatedNotices);
    } catch (error) {
      _log.e('Error deleting notice: $error');
      rethrow;
    }
  }

  Future<void> refreshNotices() async {
    _log.i('Refreshing notices');
    state = const AsyncValue.loading();
    await getNotices();
  }

  void clearNotices() {
    _log.i('Clearing notices');
    state = const AsyncValue.data([]);
  }
}
