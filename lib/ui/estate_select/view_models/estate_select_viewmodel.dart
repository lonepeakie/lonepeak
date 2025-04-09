import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';

final estateSelectViewModelProvider = Provider<EstateSelectViewmodel>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return EstateSelectViewmodel(authRepository: authRepository);
});

class EstateSelectViewmodel {
  EstateSelectViewmodel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<void> logout() async {
    await _authRepository.signOut(AuthType.google);
  }

  Future<String> getDisplayName() async {
    final result = await _authRepository.getCurrentUser();
    if (result.isFailure) {
      return '';
    }

    final user = result.data;
    return user?.displayName ?? '';
  }
}
