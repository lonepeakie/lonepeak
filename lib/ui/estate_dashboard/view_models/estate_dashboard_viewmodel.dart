import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/ui_state.dart';

class EstateDashboardViewmodel extends StateNotifier<UIState> {
  EstateDashboardViewmodel({required EstateRepository estateRepository})
    : _estateRepository = estateRepository,
      super(UIStateInitial());

  final EstateRepository _estateRepository;

  Estate get estate => _estate;
  Estate _estate = Estate.empty();

  Future<void> getEstate() async {
    state = UIStateLoading();

    final result = await _estateRepository.getEstate();
    if (result.isSuccess) {
      _estate = result.data ?? Estate.empty();
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }
}
