import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/utils/result.dart';

class EstateAlertsState {
  final List<Notice> notices;
  final bool isLoading;
  final String? errorMessage;

  EstateAlertsState({
    this.notices = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory EstateAlertsState.initial() {
    return EstateAlertsState(isLoading: true);
  }

  EstateAlertsState copyWith({
    List<Notice>? notices,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EstateAlertsState(
      notices: notices ?? this.notices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class EstateAlertsViewModel extends StateNotifier<EstateAlertsState> {
  final NoticesRepository _repository;

  EstateAlertsViewModel(this._repository) : super(EstateAlertsState.initial()) {
    getAlerts();
  }

  Future<void> getAlerts() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final Result<List<Notice>> result = await _repository.getNoticesByType(
        NoticeType.alert,
      );

      if (!result.isSuccess) {
        state = state.copyWith(errorMessage: result.error, isLoading: false);
      } else {
        final alerts = result.data!;
        alerts.sort(
          (a, b) => b.metadata!.createdAt!.compareTo(a.metadata!.createdAt!),
        );
        state = state.copyWith(notices: alerts, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<Result<void>> addAlert(Notice notice) async {
    final alertNotice = notice.copyWith(type: NoticeType.alert);
    final result = await _repository.addNotice(alertNotice);
    if (result.isSuccess) {
      await getAlerts();
    }
    return result;
  }
}
