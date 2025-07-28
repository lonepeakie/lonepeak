import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final estateHomeViewModelProvider =
    StateNotifierProvider<EstateHomeViewmodel, UIState>((ref) {
      return EstateHomeViewmodel(
        membersRepository: ref.read(membersRepositoryProvider),
        appState: ref.read(appStateProvider),
      );
    });

class EstateHomeViewmodel extends StateNotifier<UIState> {
  EstateHomeViewmodel({
    required MembersRepository membersRepository,
    required AppState appState,
  }) : _membersRepository = membersRepository,
       _appState = appState,
       super(UIStateInitial());

  final MembersRepository _membersRepository;
  final AppState _appState;

  Member? get member => _member;
  Member? _member;

  Future<void> getMember() async {
    final email = _appState.getUserId();
    final result = await _membersRepository.getMemberById(email!);
    if (result.isSuccess) {
      _member = result.data;
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to load member data');
    }
  }
}
