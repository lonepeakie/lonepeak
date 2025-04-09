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
  Future<Result<void>> addMember(Member member) {
    member.metadata = Metadata(createdAt: Timestamp.now());
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _membersService.addMember(estateId, member);
  }

  @override
  Future<Result<void>> deleteMember(String id) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _membersService.deleteMember(estateId, id);
  }

  @override
  Future<Result<Member>> getMemberById(String id) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _membersService.getMemberById(estateId, id);
  }

  @override
  Future<Result<List<Member>>> getMembers() {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _membersService.getMembers(estateId);
  }

  @override
  Future<Result<void>> updateMember(Member member) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    member.metadata = Metadata(updatedAt: Timestamp.now());
    return _membersService.updateMember(estateId, member);
  }
}
