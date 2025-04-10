import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/members/members_provider.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/utils/ui_state.dart';

final estateMembersViewModelProvider =
    StateNotifierProvider<EstateMembersViewmodel, UIState>((ref) {
      return EstateMembersViewmodel(
        membersRepository: ref.read(membersRepositoryProvider),
      );
    });

class EstateMembersViewmodel extends StateNotifier<UIState> {
  EstateMembersViewmodel({required MembersRepository membersRepository})
    : _membersRepository = membersRepository,
      super(UIStateInitial());

  final MembersRepository _membersRepository;

  List<Member> get members => _members;
  List<Member> _members = [];

  Future<void> getMembers() async {
    state = UIStateLoading();

    final result = await _membersRepository.getMembers();
    if (result.isSuccess) {
      _members = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }
}
