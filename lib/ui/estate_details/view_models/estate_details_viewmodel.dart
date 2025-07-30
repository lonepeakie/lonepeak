import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_dashboard/view_models/estate_dashboard_viewmodel.dart';

final estateDetailsViewModelProvider =
    StateNotifierProvider<EstateDetailsViewmodel, UIState>(
      (ref) => EstateDetailsViewmodel(
        estateRepository: ref.read(estateRepositoryProvider),
        dashboardViewModel: ref.read(estateDashboardViewModelProvider.notifier),
      ),
    );

class EstateDetailsViewmodel extends StateNotifier<UIState> {
  EstateDetailsViewmodel({
    required EstateRepository estateRepository,
    required EstateDashboardViewmodel dashboardViewModel,
  }) : _estateRepository = estateRepository,
       _dashboardViewModel = dashboardViewModel,
       super(UIStateInitial());

  final EstateRepository _estateRepository;
  final EstateDashboardViewmodel _dashboardViewModel;

  Future<void> updateBasicInfo({
    required String name,
    required String address,
    required String description,
  }) async {
    state = UIStateLoading();

    try {
      final currentEstate = _dashboardViewModel.estate;

      final updatedEstate = currentEstate.copyWith(
        name: name.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
      );

      final result = await _estateRepository.updateEstate(updatedEstate);

      if (result.isSuccess) {
        await _dashboardViewModel.getEstate();
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to update estate');
      }
    } catch (e) {
      state = UIStateFailure('An unexpected error occurred: $e');
    }
  }
}
