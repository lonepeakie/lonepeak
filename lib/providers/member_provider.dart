import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/auth/authn_provider.dart';
import 'package:lonepeak/utils/log_printer.dart';

// User-scoped current member provider
final currentMemberProvider = StateNotifierProvider<
  MemberProvider,
  AsyncValue<Member?>
>((ref) {
  // Watch the current user ID - provider will be recreated when this changes
  final currentUserId = ref.watch(currentUserIdProvider);

  final repository = ref.watch(membersRepositoryProvider);
  final appState = ref.watch(appStateProvider);
  return MemberProvider(repository, appState, currentUserId);
});

// User-scoped estate members provider
final estateMembersProvider = StateNotifierProvider<
  EstateMembersProvider,
  AsyncValue<List<Member>>
>((ref) {
  // Watch the current user ID - provider will be recreated when this changes
  final currentUserId = ref.watch(currentUserIdProvider);

  final repository = ref.watch(membersRepositoryProvider);
  return EstateMembersProvider(repository, currentUserId);
});

final estateMembersCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  final result = await repository.getMemberCount();

  if (result.isFailure) {
    throw Exception('Failed to fetch members count: ${result.error}');
  }

  return result.data ?? 0;
});

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

final committeeProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(membersRepositoryProvider);
  final roles = [
    'president',
    'vicepresident',
    'secretary',
    'treasurer',
    'admin',
  ];
  final result = await repository.getMembersByRoles(roles);

  if (result.isFailure) {
    throw Exception('Failed to fetch committee members: ${result.error}');
  }

  return result.data ?? [];
});

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

final pendingMembersCountProvider = FutureProvider<int>((ref) async {
  final pendingMembers = await ref.watch(pendingMembersProvider.future);
  return pendingMembers.length;
});

class MemberProvider extends StateNotifier<AsyncValue<Member?>> {
  MemberProvider(this._repository, this._appState, this._currentUserId)
    : super(const AsyncValue.loading()) {
    // Only load member if we have a valid user ID
    if (_currentUserId != null) {
      _loadCurrentMember();
    }
  }

  final MembersRepository _repository;
  final AppState _appState;
  final String? _currentUserId; // User ID that scopes this provider
  final _log = Logger(printer: PrefixedLogPrinter('MemberProvider'));

  Future<void> _loadCurrentMember() async {
    await getCurrentMember();
  }

  void ensureMemberLoaded() {
    if (state is! AsyncLoading && !state.hasValue) {
      _loadCurrentMember();
    }
  }

  Future<Member?> getCurrentMember() async {
    // If we already have a valid member and no error, return it
    if (state.hasValue && state.value != null && state is! AsyncError) {
      return state.value;
    }

    // Set loading state only if not already loading
    if (state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }

    try {
      final userId = _currentUserId ?? _appState.getUserId();
      if (userId == null) {
        _log.w('No user ID found, returning null member');
        state = const AsyncValue.data(null);
        return null;
      }

      _log.i('Fetching current member for user: $userId');
      final result = await _repository.getMemberById(userId);

      if (result.isFailure) {
        _log.e('Failed to fetch current member: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to fetch current member: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      final member = result.data;
      _log.i('Successfully fetched member: ${member?.email ?? 'null'}');
      state = AsyncValue.data(member);
      return member;
    } catch (error, stackTrace) {
      _log.e(
        'Error fetching current member: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<void> updateCurrentMember(Member member) async {
    try {
      _log.i('Updating current member: ${member.email}');

      final result = await _repository.updateMember(member);

      if (result.isFailure) {
        _log.e('Failed to update member: ${result.error}');
        throw Exception('Failed to update member: ${result.error}');
      }

      _log.i('Successfully updated member: ${member.email}');
      state = AsyncValue.data(member);
    } catch (error, stackTrace) {
      _log.e(
        'Error updating current member: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Member? get cachedMember => state.value;

  void clearMember() {
    state = const AsyncValue.data(null);
  }

  Future<void> refreshMember() async {
    state = const AsyncValue.loading();
    await getCurrentMember();
  }
}

class EstateMembersProvider extends StateNotifier<AsyncValue<List<Member>>> {
  EstateMembersProvider(this._repository, this._currentUserId)
    : super(const AsyncValue.loading()) {
    // Only load members if we have a valid user ID
    if (_currentUserId != null) {
      _loadMembers();
    }
  }

  final MembersRepository _repository;
  final String? _currentUserId; // User ID that scopes this provider
  final _log = Logger(printer: PrefixedLogPrinter('EstateMembersProvider'));
  List<Member> _cachedMembers = [];

  Future<void> _loadMembers() async {
    await getMembers();
  }

  void ensureMembersLoaded() {
    if (state is! AsyncLoading &&
        (!state.hasValue || state.value?.isEmpty == true)) {
      _loadMembers();
    }
  }

  Future<void> getMembers() async {
    if (_cachedMembers.isNotEmpty && state.hasValue && state is! AsyncError) {
      _log.i('Using cached members (${_cachedMembers.length} members)');
      return;
    }

    if (state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }

    try {
      _log.i('Fetching estate members from repository');
      final result = await _repository.getMembers();

      if (result.isFailure) {
        _log.e('Failed to fetch members: ${result.error}');
        state = AsyncValue.error(
          Exception('Failed to fetch members: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedMembers = result.data ?? [];
      _log.i('Successfully fetched ${_cachedMembers.length} members');
      state = AsyncValue.data([..._cachedMembers]);
    } catch (error, stackTrace) {
      _log.e(
        'Error fetching members: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMemberStatus(
    String memberEmail,
    MemberStatus newStatus,
  ) async {
    try {
      _log.i('Updating member status: $memberEmail to $newStatus');
      final memberIndex = _cachedMembers.indexWhere(
        (member) => member.email == memberEmail,
      );

      if (memberIndex == -1) {
        _log.e('Member not found: $memberEmail');
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
        _log.e('Failed to update member status: ${result.error}');
        throw Exception('Failed to update member status: ${result.error}');
      }

      _cachedMembers[memberIndex] = updatedMember;
      _log.i('Successfully updated member status: $memberEmail');
      state = AsyncValue.data([..._cachedMembers]);
    } catch (error) {
      _log.e('Error updating member status: $error');
      rethrow;
    }
  }

  Future<void> approveMember(String memberEmail) async {
    _log.i('Approving member: $memberEmail');
    await updateMemberStatus(memberEmail, MemberStatus.active);
  }

  Future<void> rejectMember(String memberEmail) async {
    _log.i('Rejecting member: $memberEmail');
    await updateMemberStatus(memberEmail, MemberStatus.inactive);
  }

  Future<void> updateMemberRole(String memberEmail, RoleType newRole) async {
    try {
      _log.i('Updating member role: $memberEmail to $newRole');
      final memberIndex = _cachedMembers.indexWhere(
        (member) => member.email == memberEmail,
      );

      if (memberIndex == -1) {
        _log.e('Member not found: $memberEmail');
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
        _log.e('Failed to update member role: ${result.error}');
        throw Exception('Failed to update member role: ${result.error}');
      }

      _cachedMembers[memberIndex] = updatedMember;
      _log.i('Successfully updated member role: $memberEmail');
      state = AsyncValue.data([..._cachedMembers]);
    } catch (error) {
      _log.e('Error updating member role: $error');
      rethrow;
    }
  }

  Future<void> removeMember(String memberEmail) async {
    try {
      _log.i('Removing member: $memberEmail');
      final result = await _repository.deleteMember(memberEmail);

      if (result.isFailure) {
        _log.e('Failed to remove member: ${result.error}');
        throw Exception('Failed to remove member: ${result.error}');
      }

      _cachedMembers.removeWhere((member) => member.email == memberEmail);
      _log.i('Successfully removed member: $memberEmail');
      state = AsyncValue.data([..._cachedMembers]);
    } catch (error) {
      _log.e('Error removing member: $error');
      rethrow;
    }
  }

  List<Member> get activeMembers =>
      _cachedMembers
          .where((member) => member.status == MemberStatus.active)
          .toList();

  List<Member> get pendingMembers =>
      _cachedMembers
          .where((member) => member.status == MemberStatus.pending)
          .toList();

  int get pendingMembersCount =>
      _cachedMembers
          .where((member) => member.status == MemberStatus.pending)
          .length;

  List<Member> get cachedMembers => _cachedMembers;

  Future<void> refreshMembers() async {
    _log.i('Refreshing members');
    _cachedMembers.clear();
    state = const AsyncValue.loading();
    await getMembers();
  }

  void clearMembers() {
    _log.i('Clearing members');
    _cachedMembers.clear();
    state = const AsyncValue.data([]);
  }

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

  List<Member> getMembersByStatus(MemberStatus status) {
    return _cachedMembers.where((member) => member.status == status).toList();
  }

  List<Member> getMembersByRole(RoleType role) {
    return _cachedMembers.where((member) => member.role == role).toList();
  }
}
