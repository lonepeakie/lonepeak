import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/services/estate/estate_service.dart';
import 'package:lonepeak/data/services/members/members_service.dart';
import 'package:lonepeak/data/services/users/users_service.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/utils/log_printer.dart';

final estateJoinViewModelProvider =
    StateNotifierProvider<EstateJoinViewModel, UIState>(
      (ref) => EstateJoinViewModel(
        ref.watch(estateServiceProvider),
        ref.watch(membersServiceProvider),
        ref.watch(usersServiceProvider),
      ),
    );

class EstateJoinViewModel extends StateNotifier<UIState> {
  final EstateService _estateService;
  final MembersService _membersService;
  final UsersService _usersService;
  final _log = Logger(printer: PrefixedLogPrinter('EstateJoinViewModel'));

  // State properties
  List<Estate> _availableEstates = [];
  String? _searchQuery;
  bool _requestSubmitted = false;

  // Getters for state properties
  List<Estate> get availableEstates => _availableEstates;
  String? get searchQuery => _searchQuery;
  bool get requestSubmitted => _requestSubmitted;

  EstateJoinViewModel(
    this._estateService,
    this._membersService,
    this._usersService,
  ) : super(UIStateInitial()) {
    loadAvailableEstates();
  }

  Future<void> loadAvailableEstates() async {
    state = UIStateLoading();

    try {
      final result = await _estateService.getPublicEstates();

      if (result.isSuccess) {
        _availableEstates = result.data ?? [];
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to load estates');
      }
    } catch (e) {
      _log.e('Error loading available estates: $e');
      state = UIStateFailure('Failed to load estates');
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    filterEstates();
  }

  void filterEstates() {
    // Will implement if needed
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      loadAvailableEstates();
      return;
    }

    // For now, we're just doing this client-side, but could be moved to backend
    // for better performance with large datasets
  }

  Future<void> requestToJoinEstate(String estateId) async {
    state = UIStateLoading();

    try {
      // Get current user
      final userResult = await _usersService.getUser("currentUserId");
      if (userResult.isFailure) {
        state = UIStateFailure('Failed to get current user information');
        return;
      }

      final User currentUser = userResult.data as User;

      // Create pending member request
      final member = Member(
        email: currentUser.email,
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoUrl,
        role: 'pending', // Pending approval
      );

      // Add member with pending status
      final result = await _membersService.requestToJoinEstate(
        estateId,
        member,
      );

      if (result.isSuccess) {
        _requestSubmitted = true;
        state = UIStateSuccess();
      } else {
        state = UIStateFailure(result.error ?? 'Failed to submit join request');
      }
    } catch (e) {
      _log.e('Error requesting to join estate: $e');
      state = UIStateFailure('Failed to submit join request');
    }
  }
}
