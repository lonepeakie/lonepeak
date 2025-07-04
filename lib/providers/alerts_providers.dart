import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/ui/estate_alerts/view_models/estate_alerts_view_model.dart';

final estateAlertsViewModelProvider =
    StateNotifierProvider.autoDispose<EstateAlertsViewModel, EstateAlertsState>(
      (ref) {
        final repository = ref.read(noticesRepositoryProvider);
        return EstateAlertsViewModel(repository);
      },
    );
