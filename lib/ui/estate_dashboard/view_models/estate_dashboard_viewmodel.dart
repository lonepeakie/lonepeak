import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/data/repositories/members/members_provider.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/utils/ui_state.dart';

final estateDashboardViewModelProvider =
    StateNotifierProvider<EstateDashboardViewmodel, UIState>(
      (ref) => EstateDashboardViewmodel(
        estateRepository: ref.read(estateRepositoryProvider),
        membersRepository: ref.read(membersRepositoryProvider),
      ),
    );

class EstateDashboardViewmodel extends StateNotifier<UIState> {
  EstateDashboardViewmodel({
    required EstateRepository estateRepository,
    required MembersRepository membersRepository,
  }) : _estateRepository = estateRepository,
       _membersRepository = membersRepository,
       super(UIStateInitial());

  final EstateRepository _estateRepository;
  final MembersRepository _membersRepository;

  Estate get estate => _estate;
  Estate _estate = Estate.empty();
  int get membersCount => _membersCount;
  int _membersCount = 0;

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

  Future<void> getMembersCount() async {
    state = UIStateLoading();

    final result = await _membersRepository.getMemberCount();
    if (result.isSuccess) {
      _membersCount = result.data ?? 0;
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }
}
