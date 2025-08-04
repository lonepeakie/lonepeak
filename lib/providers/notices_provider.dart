import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/domain/models/notice.dart';

/// Provider for all notices with caching and state management
final noticesProvider =
    StateNotifierProvider<NoticesProvider, AsyncValue<List<Notice>>>((ref) {
      final repository = ref.watch(noticesRepositoryProvider);
      return NoticesProvider(repository);
    });

/// Provider for latest notices (subset of all notices)
final latestNoticesProvider = FutureProvider<List<Notice>>((ref) async {
  final repository = ref.watch(noticesRepositoryProvider);
  final result = await repository.getLatestNotices();

  if (result.isFailure) {
    throw Exception('Failed to fetch latest notices: ${result.error}');
  }

  return result.data ?? [];
});

class NoticesProvider extends StateNotifier<AsyncValue<List<Notice>>> {
  NoticesProvider(this._repository) : super(const AsyncValue.data([]));

  final NoticesRepository _repository;
  List<Notice> _cachedNotices = [];

  /// Get all notices from cache or fetch if empty
  Future<void> getNotices() async {
    if (_cachedNotices.isNotEmpty) {
      state = AsyncValue.data(_cachedNotices);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _repository.getNotices();

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to fetch notices: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedNotices = result.data ?? [];
      state = AsyncValue.data(_cachedNotices);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new notice
  Future<void> addNotice(Notice notice) async {
    try {
      final result = await _repository.addNotice(notice);

      if (result.isFailure) {
        throw Exception('Failed to create notice: ${result.error}');
      }

      // Add to cached list and update state
      _cachedNotices.add(notice);
      state = AsyncValue.data([..._cachedNotices]);
    } catch (error) {
      // Don't update state on error, just throw for UI to handle
      throw error;
    }
  }

  /// Toggle like on a notice
  Future<void> toggleLike(String noticeId) async {
    try {
      final result = await _repository.toggleLike(noticeId);

      if (result.isFailure) {
        throw Exception('Failed to toggle like: ${result.error}');
      }

      // Update the notice in cached list
      final updatedNotice = result.data!;
      final index = _cachedNotices.indexWhere(
        (notice) => notice.id == noticeId,
      );

      if (index != -1) {
        _cachedNotices[index] = updatedNotice;
        state = AsyncValue.data([..._cachedNotices]);
      }
    } catch (error) {
      // Don't throw for likes to avoid UI disruption
      // Just fail silently or log the error
    }
  }

  /// Update an existing notice
  Future<void> updateNotice(Notice notice) async {
    try {
      final result = await _repository.updateNotice(notice);

      if (result.isFailure) {
        throw Exception('Failed to update notice: ${result.error}');
      }

      // Update in cached list
      final index = _cachedNotices.indexWhere((n) => n.id == notice.id);
      if (index != -1) {
        _cachedNotices[index] = notice;
        state = AsyncValue.data([..._cachedNotices]);
      }
    } catch (error) {
      throw error;
    }
  }

  /// Delete a notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      final result = await _repository.deleteNotice(noticeId);

      if (result.isFailure) {
        throw Exception('Failed to delete notice: ${result.error}');
      }

      // Remove from cached list
      _cachedNotices.removeWhere((notice) => notice.id == noticeId);
      state = AsyncValue.data([..._cachedNotices]);
    } catch (error) {
      throw error;
    }
  }

  /// Refresh notices from repository
  Future<void> refreshNotices() async {
    _cachedNotices.clear();
    await getNotices();
  }

  /// Clear cached notices
  void clearNotices() {
    _cachedNotices.clear();
    state = const AsyncValue.data([]);
  }

  /// Get cached notices (synchronous)
  List<Notice> get cachedNotices => _cachedNotices;
}
