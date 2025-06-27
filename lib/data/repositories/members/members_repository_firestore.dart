import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/services/members/members_service.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final membersRepositoryProvider = Provider<MembersRepositoryFirestore>((ref) {
  return MembersRepositoryFirestore(
    membersService: ref.read(membersServiceProvider),
    appState: ref.read(appStateProvider),
  );
});

class MembersRepositoryFirestore extends MembersRepository {
  MembersRepositoryFirestore({
    required AppState appState,
    required MembersService membersService,
  }) : _membersService = membersService,
       _appState = appState;

  final MembersService _membersService;
  final AppState _appState;

  @override
  Future<Result<void>> addMember(Member member) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userId = _appState.getUserId();
    final updatedMember = member.copyWith(
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userId),
    );
    return _membersService.addMember(estateId, updatedMember);
  }

  @override
  Future<Result<void>> deleteMember(String id) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _membersService.deleteMember(estateId, id);
  }

  @override
  Future<Result<Member>> getMemberById(String id) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _membersService.getMemberById(estateId, id);
  }

  @override
  Future<Result<List<Member>>> getMembers() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _membersService.getMembers(estateId);
  }

  @override
  Future<Result<int>> getMemberCount() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _membersService.getMemberCount(estateId);
  }

  @override
  Future<Result<List<Member>>> getMembersByRoles(List<String> roles) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _membersService.getMembersByRoles(estateId, roles);
  }

  @override
  Future<Result<void>> updateMember(Member member) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userId = _appState.getUserId();
    final updatedMember = member.copyWith(
      metadata: member.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userId,
      ),
    );
    return _membersService.updateMember(estateId, updatedMember);
  }
}
