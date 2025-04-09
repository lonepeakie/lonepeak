import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/ui_state.dart';

final estateCreateViewModelProvider =
    StateNotifierProvider<EstateCreateViewmodel, UIState>((ref) {
      return EstateCreateViewmodel(
        estateFeatures: ref.read(estateFeaturesProvider),
      );
    });

class EstateCreateViewmodel extends StateNotifier<UIState> {
  EstateCreateViewmodel({required EstateFeatures estateFeatures})
    : _estateFeatures = estateFeatures,
      super(UIStateInitial());

  final EstateFeatures _estateFeatures;

  Future<void> createEstate(Estate estate) async {
    state = UIStateLoading();

    final result = await _estateFeatures.createEstateAndAddMember(estate);
    if (result.isSuccess) {
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }
}
