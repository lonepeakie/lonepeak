import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

final userProfileViewModelProvider =
    StateNotifierProvider<UserProfileViewModel, UIState>((ref) {
      return UserProfileViewModel(
        userSiginFeature: ref.read(userSiginFeatureProvider),
        usersRepository: ref.read(usersRepositoryProvider),
        estateFeatures: ref.read(estateFeaturesProvider),
        appState: ref.read(appStateProvider),
      );
    });

class UserProfileViewModel extends StateNotifier<UIState> {
  final UserSiginFeature userSiginFeature;
  final UsersRepository usersRepository;
  final EstateFeatures estateFeatures;
  final AppState appState;

  User? _user;
  User? get user => _user;

  UserProfileViewModel({
    required this.userSiginFeature,
    required this.usersRepository,
    required this.estateFeatures,
    required this.appState,
  }) : super(UIStateInitial()) {
    getUserProfile();
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
