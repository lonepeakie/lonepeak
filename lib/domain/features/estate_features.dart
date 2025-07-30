import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final estateFeaturesProvider = Provider<EstateFeatures>((ref) {
  final estateRepository = ref.read(estateRepositoryProvider);
  final membersRepository = ref.read(membersRepositoryProvider);
  final authRepository = ref.read(authRepositoryProvider);
  final usersRepository = ref.read(usersRepositoryProvider);
  final appState = ref.read(appStateProvider);

  return EstateFeatures(
    estateRepository: estateRepository,
    membersRepository: membersRepository,
    authRepository: authRepository,
    usersRepository: usersRepository,
    appState: appState,
  );
});

class EstateFeatures {
  EstateFeatures({
    required EstateRepository estateRepository,
    required MembersRepository membersRepository,
    required AuthRepository authRepository,
    required UsersRepository usersRepository,
    required AppState appState,
  }) : _estateRepository = estateRepository,
       _membersRepository = membersRepository,
       _authRepository = authRepository,
       _usersRepository = usersRepository,
       _appState = appState;

  final EstateRepository _estateRepository;
  final MembersRepository _membersRepository;
  final AuthRepository _authRepository;
  final UsersRepository _usersRepository;
  final AppState _appState;

  Future<Result<void>> createEstateAndAddMember(Estate estateData) async {
    final authResult = _authRepository.getCurrentUser();
    if (authResult.isFailure) {
      return Result.failure('Failed to get current user: ${authResult.error}');
    }
    final currentUser = authResult.data;
    if (currentUser == null) {
      return Result.failure('Current user is null');
    }

    final estateResult = await _estateRepository.addEstate(estateData);
    if (estateResult.isFailure) {
      return Result.failure('Failed to create estate: ${estateResult.error}');
    }

    final String estateId = estateResult.data as String;
    _appState.setEstateId(estateId);

    final member = Member(
      email: currentUser.email,
      displayName: currentUser.displayName,
      role: RoleType.admin,
      status: MemberStatus.active,
    );

    final memberResult = await _membersRepository.addMember(member);
    if (memberResult.isFailure) {
      final estateDeleteResult = await _estateRepository.deleteEstate();
      if (estateDeleteResult.isFailure) {
        return Result.failure(
          'Failed to delete estate after member addition failure',
        );
      }

      return Result.failure('Failed to add member: ${memberResult.error}');
    }

    final addEstateToUserResult = await _addEstateToUser(
      currentUser.email,
      estateId,
    );
    if (addEstateToUserResult.isFailure) {
      return Result.failure(
        'Failed to add estate to user: ${addEstateToUserResult.error}',
      );
    }

    _appState.setEstateId(estateId);
    return Result.success(null);
  }

  Future<Result<void>> requestToJoinEstate(String estateId) async {
    final userEmail = _appState.getUserId();
    if (userEmail == null) {
      return Result.failure('User email is null');
    }

    final currentUserResult = await _usersRepository.getUser(userEmail);
    if (currentUserResult.isFailure || currentUserResult.data == null) {
      return Result.failure('Failed to get user: ${currentUserResult.error}');
    }
    final currentUser = currentUserResult.data;

    _appState.setEstateId(estateId);

    final member = Member(
      email: currentUser?.email ?? '',
      displayName: currentUser?.displayName ?? '',
      role: RoleType.resident,
      status: MemberStatus.pending,
    );

    final result = await _membersRepository.addMember(member);
    if (result.isFailure) {
      return Result.failure('Failed to add member: ${result.error}');
    }

    final addEstateToUserResult = await _addEstateToUser(userEmail, estateId);
    if (addEstateToUserResult.isFailure) {
      return Result.failure(
        'Failed to add estate to user: ${addEstateToUserResult.error}',
      );
    }

    return Result.success(null);
  }

  Future<Result<void>> exitEstate() async {
    final userEmail = _appState.getUserId();
    if (userEmail == null) {
      return Result.failure('User email is null');
    }

    final memberResult = await _membersRepository.getMemberById(userEmail);
    if (memberResult.isFailure) {
      return Result.failure('Failed to remove member: ${memberResult.error}');
    }

    final member = memberResult.data;
    if (member == null) {
      return Result.failure('Member not found');
    }

    final updatedMember = member.copyWith(status: MemberStatus.inactive);

    final updateResult = await _membersRepository.updateMember(updatedMember);
    if (updateResult.isFailure) {
      return Result.failure(
        'Failed to update member status: ${updateResult.error}',
      );
    }

    final user = await _usersRepository.getUser(userEmail);
    if (user.isFailure || user.data == null) {
      return Result.failure('Failed to get user: ${user.error}');
    }

    final updatedUser = user.data!.copyWithEmptyEstateId();
    final userUpdateResult = await _usersRepository.updateUser(updatedUser);
    if (userUpdateResult.isFailure) {
      return Result.failure('Failed to update user: ${userUpdateResult.error}');
    }

    final clearEstateResult = await _appState.clearEstateId();
    if (clearEstateResult.isFailure) {
      return Result.failure(
        'Failed to clear estate ID: ${clearEstateResult.error}',
      );
    }

    return Result.success(null);
  }

  Future<Result<void>> _addEstateToUser(
    String userEmail,
    String estateId,
  ) async {
    final userResult = await _usersRepository.getUser(userEmail);
    if (userResult.isFailure || userResult.data == null) {
      return Result.failure('Failed to get user: ${userResult.error}');
    }
    final currentUser = userResult.data!;

    final updatedUser = currentUser.copyWith(estateId: estateId);
    final updateResult = await _usersRepository.updateUser(updatedUser);
    if (updateResult.isFailure) {
      return Result.failure('Failed to update user: ${updateResult.error}');
    }

    return Result.success(null);
  }
}
