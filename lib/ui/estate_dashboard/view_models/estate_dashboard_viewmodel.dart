import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/data/repositories/members/members_repository.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository.dart';
import 'package:lonepeak/data/repositories/notice/notices_repository_firestore.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/notice.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final estateDashboardViewModelProvider =
    StateNotifierProvider<EstateDashboardViewmodel, UIState>(
      (ref) => EstateDashboardViewmodel(
        estateRepository: ref.read(estateRepositoryProvider),
        membersRepository: ref.read(membersRepositoryProvider),
        noticesRepository: ref.read(noticesRepositoryProvider),
      ),
    );

class EstateDashboardViewmodel extends StateNotifier<UIState> {
  EstateDashboardViewmodel({
    required EstateRepository estateRepository,
    required MembersRepository membersRepository,
    required NoticesRepository noticesRepository,
  }) : _estateRepository = estateRepository,
       _membersRepository = membersRepository,
       _noticesRepository = noticesRepository,
       super(UIStateInitial());

  final EstateRepository _estateRepository;
  final MembersRepository _membersRepository;
  final NoticesRepository _noticesRepository;

  Estate get estate => _estate;
  Estate _estate = Estate.empty();
  int get membersCount => _membersCount;
  int _membersCount = 0;
  List<Member> get committeeMembers => _committeeMembers;
  List<Member> _committeeMembers = [];
  List<Notice> get notices => _notices;
  List<Notice> _notices = [];

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

  Future<void> getCommitteeMembers() async {
    state = UIStateLoading();
    final committeeRoles = [
      'president',
      'vicepresident',
      'secretary',
      'treasurer',
      'admin',
    ];

    final result = await _membersRepository.getMembersByRoles(committeeRoles);
    if (result.isSuccess) {
      _committeeMembers = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }

  Future<void> getLatestNotices() async {
    state = UIStateLoading();

    final result = await _noticesRepository.getLatestNotices();
    if (result.isSuccess) {
      _notices = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }
}
