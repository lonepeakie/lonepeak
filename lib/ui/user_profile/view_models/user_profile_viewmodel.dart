import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final userProfileViewModelProvider =
    StateNotifierProvider<UserProfileViewModel, UIState>((ref) {
      return UserProfileViewModel(
        userSiginFeature: ref.read(userSiginFeatureProvider),
        usersRepository: ref.read(usersRepositoryProvider),
        estateRepository: ref.read(estateRepositoryProvider),
        estateFeatures: ref.read(estateFeaturesProvider),
        appState: ref.read(appStateProvider),
      );
    });

class UserProfileViewModel extends StateNotifier<UIState> {
  final UserSiginFeature userSiginFeature;
  final UsersRepository usersRepository;
  final EstateRepository estateRepository;
  final EstateFeatures estateFeatures;
  final AppState appState;

  User? _user;
  Estate? _estate;

  User? get user => _user;
  Estate? get estate => _estate;

  UserProfileViewModel({
    required this.userSiginFeature,
    required this.usersRepository,
    required this.estateRepository,
    required this.estateFeatures,
    required this.appState,
  }) : super(UIStateInitial()) {
    getUserProfile();
    getEstate();
  }

  Future<void> getUserProfile() async {
    state = UIStateLoading();

    try {
      final currentUser = appState.getUserId();
      if (currentUser == null) {
        state = UIStateFailure('No user is currently signed in.');
        return;
      }

      final userResult = await usersRepository.getUser(currentUser);
      if (userResult.isFailure) {
        state = UIStateFailure(userResult.error!);
        return;
      }

      _user = userResult.data;
      state = UIStateSuccess();
    } catch (e) {
      state = UIStateFailure(e.toString());
    }
  }

  Future<void> getEstate() async {
    try {
      final estateResult = await estateRepository.getEstate();
      if (estateResult.isSuccess) {
        _estate = estateResult.data;
      }
    } catch (e) {
      state = UIStateFailure(e.toString());
    }
  }

  Future<bool> logout() async {
    state = UIStateLoading();

    try {
      final result = await userSiginFeature.logOut();
      if (result.isSuccess) {
        state = UIStateSuccess();
        return true;
      } else {
        state = UIStateFailure(result.error ?? 'Logout failed');
        return false;
      }
    } catch (e) {
      state = UIStateFailure(e.toString());
      return false;
    }
  }

  Future<bool> exitEstate() async {
    state = UIStateLoading();

    final result = await estateFeatures.exitEstate();
    if (result.isFailure) {
      state = UIStateFailure(result.error ?? 'Failed to exit estate');
      return false;
    }
    _user = null;
    state = UIStateSuccess();
    return true;
  }
}
