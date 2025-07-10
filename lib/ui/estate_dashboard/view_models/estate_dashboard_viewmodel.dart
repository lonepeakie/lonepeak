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

  Estate _estate = Estate.empty();
  int _membersCount = 0;
  List<Member> _committeeMembers = [];
  List<Notice> _allNotices = [];

  Estate get estate => _estate;
  int get membersCount => _membersCount;
  List<Member> get committeeMembers => _committeeMembers;

  List<Notice> get latestNoticesForDashboard {
    return _allNotices.take(3).toList();
  }

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
      _allNotices = result.data ?? [];
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Unknown error');
    }
  }

  Future<void> updateEstate(Map<String, String> updatedData) async {
    state = UIStateLoading();
    final estateToUpdate = _estate.copyWith(
      name: updatedData['name'],
      description: updatedData['description'],
      address: updatedData['address'],
      city: updatedData['city'],
      county: updatedData['county'],
    );

    final result = await _estateRepository.updateEstate(estateToUpdate);

    if (result.isSuccess) {
      _estate = estateToUpdate;
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to update estate');
    }
  }

  Future<void> updateEstateLinks(List<Map<String, String>> newLinks) async {
    state = UIStateLoading();

    final estateToUpdate = _estate.copyWith(webLinks: newLinks);

    final result = await _estateRepository.updateEstate(estateToUpdate);

    if (result.isSuccess) {
      _estate = estateToUpdate;
      state = UIStateSuccess();
    } else {
      state = UIStateFailure(result.error ?? 'Failed to update links');
    }
  }

  Future<void> toggleLike(String noticeId) async {
    final result = await _noticesRepository.toggleLike(noticeId);

    if (result.isSuccess) {
      final updatedNotice = result.data!;
      final index = _allNotices.indexWhere((notice) => notice.id == noticeId);

      if (index != -1) {
        _allNotices[index] = updatedNotice;
        state = UIStateSuccess();
      }
    }
  }
}
