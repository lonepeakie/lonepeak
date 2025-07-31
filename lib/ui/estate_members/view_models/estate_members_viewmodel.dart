import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final estateMembersViewModelProvider =
    StateNotifierProvider<EstateMembersViewmodel, UIState>((ref) {
      return EstateMembersViewmodel(
        membersRepository: ref.read(membersRepositoryProvider),
        appState: ref.read(appStateProvider),
      );
    });

class EstateMembersViewmodel extends StateNotifier<UIState> {
  EstateMembersViewmodel({
    required MembersRepository membersRepository,
    required AppState appState,
  }) : _membersRepository = membersRepository,
       _appState = appState,
       super(UIStateInitial());

  final MembersRepository _membersRepository;
  final AppState _appState;

  List<Member> _members = [];
  List<Member> get activeMembers =>
      _members.where((member) => member.status == MemberStatus.active).toList();
  List<Member> get pendingMembers =>
      _members
          .where((member) => member.status == MemberStatus.pending)
          .toList();
  int get pendingMembersCount =>
      _members.where((member) => member.status == MemberStatus.pending).length;

  Future<void> getMembers() async {
    state = UIStateLoading();

    final result = await _membersRepository.getMembers();
    if (result.isSuccess) {
      _members = result.data ?? [];

      await _updateCurrentUserRoleInAppState();

      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }

  Future<void> _updateCurrentUserRoleInAppState() async {
    final userEmail = _appState.getUserId();
    if (userEmail == null) return;

    final memberIndex = _members.indexWhere(
      (member) => member.email == userEmail,
    );

    if (memberIndex != -1) {
      await _appState.setUserRole(_members[memberIndex].role.name);
    }
  }

  Future<void> updateMemberStatus(
    String memberEmail,
    MemberStatus newStatus,
  ) async {
    state = UIStateLoading();

    final memberIndex = _members.indexWhere(
      (member) => member.email == memberEmail,
    );
    if (memberIndex == -1) {
      state = UIStateFailure('Member not found');
      return;
    }

    final currentMember = _members[memberIndex];
    final updatedMember = Member(
      email: currentMember.email,
      displayName: currentMember.displayName,
      role: currentMember.role,
      status: newStatus,
      metadata: currentMember.metadata,
    );

    final result = await _membersRepository.updateMember(updatedMember);
    if (result.isSuccess) {
      _members[memberIndex] = updatedMember;
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to update member status');
    }
  }

  Future<void> approveMember(String memberEmail) async {
    await updateMemberStatus(memberEmail, MemberStatus.active);
  }

  Future<void> rejectMember(String memberEmail) async {
    await updateMemberStatus(memberEmail, MemberStatus.inactive);
  }

  Future<void> updateMemberRole(String memberEmail, RoleType newRole) async {
    state = UIStateLoading();

    final memberIndex = _members.indexWhere(
      (member) => member.email == memberEmail,
    );
    if (memberIndex == -1) {
      state = UIStateFailure('Member not found');
      return;
    }

    final currentMember = _members[memberIndex];
    final updatedMember = Member(
      email: currentMember.email,
      displayName: currentMember.displayName,
      role: newRole,
      status: currentMember.status,
      metadata: currentMember.metadata,
    );

    final result = await _membersRepository.updateMember(updatedMember);
    if (result.isSuccess) {
      _members[memberIndex] = updatedMember;
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to update member role');
    }
  }

  Future<void> removeMember(String memberEmail) async {
    state = UIStateLoading();

    final result = await _membersRepository.deleteMember(memberEmail);
    if (result.isSuccess) {
      _members.removeWhere((member) => member.email == memberEmail);
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to remove member');
    }
  }

  Future<bool> hasAdminPrivileges() async {
    final role = await _appState.getUserRole();
    if (role != null) {
      return RoleType.hasAdminPrivileges(RoleType.fromString(role));
    }

    final userEmail = _appState.getUserId();
    if (userEmail == null) return false;

    final memberIndex = _members.indexWhere(
      (member) => member.email == userEmail,
    );

    if (memberIndex == -1) {
      return false;
    }

    final memberRole = _members[memberIndex].role;

    _appState.setUserRole(memberRole.name);

    return RoleType.hasAdminPrivileges(memberRole);
  }
}
