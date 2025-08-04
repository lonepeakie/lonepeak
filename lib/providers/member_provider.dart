import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

/// Provider for current authenticated member with caching
final memberProvider =
    StateNotifierProvider<MemberProvider, AsyncValue<Member?>>((ref) {
      final repository = ref.watch(membersRepositoryProvider);
      final appState = ref.watch(appStateProvider);
      return MemberProvider(repository, appState);
    });

/// Provider for all estate members with management capabilities
final estateMembersProvider =
    StateNotifierProvider<EstateMembersProvider, AsyncValue<List<Member>>>((
      ref,
    ) {
      final repository = ref.watch(membersRepositoryProvider);
      final appState = ref.watch(appStateProvider);
      return EstateMembersProvider(repository, appState);
    });

/// Provider for active members only
final activeMembersProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  final result = await repository.getMembers();

  if (result.isFailure) {
    throw Exception('Failed to fetch members: ${result.error}');
  }

  return (result.data ?? [])
      .where((member) => member.status == MemberStatus.active)
      .toList();
});

/// Provider for pending members (awaiting approval)
final pendingMembersProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  final result = await repository.getMembers();

  if (result.isFailure) {
    throw Exception('Failed to fetch members: ${result.error}');
  }

  return (result.data ?? [])
      .where((member) => member.status == MemberStatus.pending)
      .toList();
});

/// Provider for pending members count
final pendingMembersCountProvider = FutureProvider<int>((ref) async {
  final pendingMembers = await ref.watch(pendingMembersProvider.future);
  return pendingMembers.length;
});

class MemberProvider extends StateNotifier<AsyncValue<Member?>> {
  MemberProvider(this._repository, this._appState)
    : super(const AsyncValue.data(null));

  final MembersRepository _repository;
  final AppState _appState;
  Member? _cachedMember;

  /// Get current member from cache or fetch if not available
  Future<Member?> getCurrentMember() async {
    if (_cachedMember != null) {
      state = AsyncValue.data(_cachedMember);
      return _cachedMember;
    }

    state = const AsyncValue.loading();

    try {
      final userId = _appState.getUserId();
      if (userId == null) {
        state = const AsyncValue.data(null);
        return null;
      }

      final result = await _repository.getMemberById(userId);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to fetch current member: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      _cachedMember = result.data;
      state = AsyncValue.data(_cachedMember);

      // Update app state with user role
      if (_cachedMember != null) {
        await _appState.setUserRole(_cachedMember!.role.name);
      }

      return _cachedMember;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Update current member and refresh cache
  Future<void> updateCurrentMember(Member member) async {
    try {
      final result = await _repository.updateMember(member);

      if (result.isFailure) {
        throw Exception('Failed to update member: ${result.error}');
      }

      _cachedMember = member;
      state = AsyncValue.data(_cachedMember);

      // Update app state with new role
      await _appState.setUserRole(member.role.name);
    } catch (error) {
      throw error;
    }
  }

  /// Get cached member (synchronous)
  Member? get cachedMember => _cachedMember;

  /// Check if current user has admin privileges
  Future<bool> hasAdminPrivileges() async {
    final role = await _appState.getUserRole();
    if (role != null) {
      return RoleType.hasAdminPrivileges(RoleType.fromString(role));
    }

    final member = await getCurrentMember();
    if (member == null) return false;

    return RoleType.hasAdminPrivileges(member.role);
  }

  /// Clear cached member data
  void clearMember() {
    _cachedMember = null;
    state = const AsyncValue.data(null);
  }
}

class EstateMembersProvider extends StateNotifier<AsyncValue<List<Member>>> {
  EstateMembersProvider(this._repository, this._appState)
    : super(const AsyncValue.data([]));

  final MembersRepository _repository;
  final AppState _appState;
  List<Member> _cachedMembers = [];

  /// Get all members from cache or fetch
  Future<void> getMembers() async {
    if (_cachedMembers.isNotEmpty) {
      state = AsyncValue.data([..._cachedMembers]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _repository.getMembers();

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to fetch members: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedMembers = result.data ?? [];
      state = AsyncValue.data([..._cachedMembers]);

      // Update current user role in app state
      await _updateCurrentUserRoleInAppState();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update current user's role in app state
  Future<void> _updateCurrentUserRoleInAppState() async {
    final userEmail = _appState.getUserId();
    if (userEmail == null) return;

    final memberIndex = _cachedMembers.indexWhere(
      (member) => member.email == userEmail,
    );

    if (memberIndex != -1) {
      await _appState.setUserRole(_cachedMembers[memberIndex].role.name);
    }
  }

  /// Update member status (approve/reject)
  Future<void> updateMemberStatus(
    String memberEmail,
    MemberStatus newStatus,
  ) async {
    try {
      final memberIndex = _cachedMembers.indexWhere(
        (member) => member.email == memberEmail,
      );

      if (memberIndex == -1) {
        throw Exception('Member not found');
      }

      final currentMember = _cachedMembers[memberIndex];
      final updatedMember = Member(
        email: currentMember.email,
        displayName: currentMember.displayName,
        role: currentMember.role,
        status: newStatus,
        metadata: currentMember.metadata,
      );

      final result = await _repository.updateMember(updatedMember);

      if (result.isFailure) {
        throw Exception('Failed to update member status: ${result.error}');
      }

      _cachedMembers[memberIndex] = updatedMember;
      state = AsyncValue.data([..._cachedMembers]);
    } catch (error) {
      throw error;
    }
  }

  /// Approve a pending member
  Future<void> approveMember(String memberEmail) async {
    await updateMemberStatus(memberEmail, MemberStatus.active);
  }

  /// Reject a pending member
  Future<void> rejectMember(String memberEmail) async {
    await updateMemberStatus(memberEmail, MemberStatus.inactive);
  }

  /// Update member role
  Future<void> updateMemberRole(String memberEmail, RoleType newRole) async {
    try {
      final memberIndex = _cachedMembers.indexWhere(
        (member) => member.email == memberEmail,
      );

      if (memberIndex == -1) {
        throw Exception('Member not found');
      }

      final currentMember = _cachedMembers[memberIndex];
      final updatedMember = Member(
        email: currentMember.email,
        displayName: currentMember.displayName,
        role: newRole,
        status: currentMember.status,
        metadata: currentMember.metadata,
      );

      final result = await _repository.updateMember(updatedMember);

      if (result.isFailure) {
        throw Exception('Failed to update member role: ${result.error}');
      }

      _cachedMembers[memberIndex] = updatedMember;
      state = AsyncValue.data([..._cachedMembers]);
    } catch (error) {
      throw error;
    }
  }

  /// Remove a member from the estate
  Future<void> removeMember(String memberEmail) async {
    try {
      final result = await _repository.deleteMember(memberEmail);

      if (result.isFailure) {
        throw Exception('Failed to remove member: ${result.error}');
      }

      _cachedMembers.removeWhere((member) => member.email == memberEmail);
      state = AsyncValue.data([..._cachedMembers]);
    } catch (error) {
      throw error;
    }
  }

  /// Get active members only
  List<Member> get activeMembers =>
      _cachedMembers
          .where((member) => member.status == MemberStatus.active)
          .toList();

  /// Get pending members only
  List<Member> get pendingMembers =>
      _cachedMembers
          .where((member) => member.status == MemberStatus.pending)
          .toList();

  /// Get pending members count
  int get pendingMembersCount =>
      _cachedMembers
          .where((member) => member.status == MemberStatus.pending)
          .length;

  /// Get cached members (synchronous)
  List<Member> get cachedMembers => _cachedMembers;

  /// Refresh members from repository
  Future<void> refreshMembers() async {
    _cachedMembers.clear();
    await getMembers();
  }

  /// Clear cached members
  void clearMembers() {
    _cachedMembers.clear();
    state = const AsyncValue.data([]);
  }

  /// Search members by name or email
  List<Member> searchMembers(String query) {
    if (query.isEmpty) return _cachedMembers;

    final lowercaseQuery = query.toLowerCase();
    return _cachedMembers
        .where(
          (member) =>
              member.displayName.toLowerCase().contains(lowercaseQuery) ||
              member.email.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  /// Get members by status
  List<Member> getMembersByStatus(MemberStatus status) {
    return _cachedMembers.where((member) => member.status == status).toList();
  }

  /// Get members by role
  List<Member> getMembersByRole(RoleType role) {
    return _cachedMembers.where((member) => member.role == role).toList();
  }
}
