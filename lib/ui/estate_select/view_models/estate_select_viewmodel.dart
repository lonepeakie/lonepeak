import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository_firebase.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';

final estateSelectViewModelProvider = Provider<EstateSelectViewmodel>((ref) {
  return EstateSelectViewmodel(
    authRepository: ref.read(authRepositoryProvider),
    userSiginFeature: ref.read(userSiginFeatureProvider),
  );
});

class EstateSelectViewmodel {
  EstateSelectViewmodel({
    required AuthRepository authRepository,
    required UserSiginFeature userSiginFeature,
  }) : _authRepository = authRepository,
       _userSiginFeature = userSiginFeature;

  final AuthRepository _authRepository;
  final UserSiginFeature _userSiginFeature;

  Future<void> logout() async {
    await _userSiginFeature.logOut();
  }

  Future<String> getDisplayName() async {
    final result = _authRepository.getCurrentUser();
    if (result.isFailure) {
      return '';
    }

    final user = result.data;
    return user?.displayName ?? '';
  }
}
