import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final estateProvider = StateNotifierProvider<EstateProvider, UIState>((ref) {
  final estateRepository = ref.watch(estateRepositoryProvider);
  return EstateProvider(estateRepository);
});

class EstateProvider extends StateNotifier<UIState> {
  EstateProvider(this._estateRepository) : super(UIStateLoading()) {
    loadEstate();
  }

  final EstateRepository _estateRepository;
  Estate _estate = Estate.empty();

  Estate get estate => _estate;

  Future<void> loadEstate() async {
    state = UIStateLoading();

    final result = await _estateRepository.getEstate();

    if (result.isSuccess) {
      _estate = result.data ?? Estate.empty();
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }

  Future<void> clearEstate() async {
    _estate = Estate.empty();
    state = UIStateInitial();
  }

  Future<void> refreshEstate() async {
    await loadEstate();
  }

  void updateEstate(Estate estate) {
    _estate = estate;
    state = UIStateSuccess();
  }
}
