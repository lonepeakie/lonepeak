import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/data/repositories/members/members_provider.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/repositories/users/users_provider.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/metadata.dart';
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
    // Get the current user
    final authResult = await _authRepository.getCurrentUser();
    if (authResult.isFailure) {
      return Result.failure('Failed to get current user');
    }
    final currentUser = authResult.data;
    if (currentUser == null) {
      return Result.failure('Current user is null');
    }

    // Create the estate
    estateData.metadata = Metadata(
      createdAt: Timestamp.now(),
      createdBy: currentUser.email,
    );
    final estateResult = await _estateRepository.addEstate(estateData);
    if (estateResult.isFailure) {
      return Result.failure('Failed to create estate');
    }

    final String estateId = estateResult.data as String;
    _appState.setEstateId(estateId);

    // Create the member
    final member = Member(
      email: currentUser.email,
      displayName: currentUser.displayName,
      role: RoleType.admin.name,
      metadata: Metadata(
        createdAt: Timestamp.now(),
        createdBy: currentUser.email,
      ),
    );

    // Add the member
    final memberResult = await _membersRepository.addMember(member);
    if (memberResult.isFailure) {
      // If adding the member fails, delete the estate
      final estateDeleteResult = await _estateRepository.deleteEstate();
      if (estateDeleteResult.isFailure) {
        return Result.failure(
          'Failed to delete estate after member addition failure',
        );
      }

      return Result.failure('Failed to add member');
    }

    _appState.setEstateId(estateId);
    _appState.setUserEmail(currentUser.email);
    return Result.success(null);
  }

  Future<Result<void>> setUserAndEstateId() async {
    final authResult = await _authRepository.getCurrentUser();
    if (authResult.isFailure) {
      return Result.failure('Failed to get current user');
    }
    final currentUser = authResult.data;
    if (currentUser == null) {
      return Result.failure('Current user is null');
    }

    _appState.setUserEmail(currentUser.email);

    final storedUser = await _usersRepository.getUser(currentUser.email);
    if (storedUser.isFailure) {
      return Result.failure('Failed to get user');
    }
    final user = storedUser.data;
    if (user == null) {
      return Result.failure('User not found');
    }

    if (user.estateId != null) {
      _appState.setEstateId(user.estateId!);
    }

    return Result.success(null);
  }

  Future<Result<void>> requestToJoinEstate(String estateId) async {
    final userEmail = _appState.getUserEmail;
    if (userEmail == null) {
      return Result.failure('User email is null');
    }

    final currentUserResult = await _usersRepository.getUser(userEmail);
    if (currentUserResult.isFailure || currentUserResult.data == null) {
      return Result.failure('Failed to get user');
    }
    final currentUser = currentUserResult.data;

    final member = Member(
      email: currentUser?.email ?? '',
      displayName: currentUser?.displayName ?? '',
      role: RoleType.resident.name,
      status: MemberStatus.pending,
    );

    _appState.setEstateId(estateId);
    _appState.setUserEmail(currentUser?.email ?? '');

    final result = await _membersRepository.addMember(member);
    if (result.isFailure) {
      return Result.failure('Failed to add member');
    }

    return Result.success(null);
  }
}
