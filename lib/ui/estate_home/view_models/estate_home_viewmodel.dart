import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final estateHomeViewModelProvider =
    StateNotifierProvider<EstateHomeViewmodel, UIState>((ref) {
      return EstateHomeViewmodel(
        estateFeatures: ref.read(estateFeaturesProvider),
      );
    });

class EstateHomeViewmodel extends StateNotifier<UIState> {
  EstateHomeViewmodel({required EstateFeatures estateFeatures})
    : _estateFeatures = estateFeatures,
      super(UIStateInitial());

  final EstateFeatures _estateFeatures;

  Future<void> setUserAndEstateId() async {
    state = UIStateLoading();

    final result = await _estateFeatures.setUserAndEstateId();
    if (result.isSuccess) {
      state = UIStateSuccess();
    } else {
      state = UIStateFailure('User not found');
    }
  }
}
