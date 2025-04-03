import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/auth/app_user.dart';
import 'package:lonepeak/data/repositories/auth/auth_provider.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';

final estateSelectViewModelProvider = Provider<EstateSelectViewmodel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return EstateSelectViewmodel(authRepository: authRepository);
});

class EstateSelectViewmodel {
  EstateSelectViewmodel({required this.authRepository});

  final AuthRepository authRepository;

  Future<void> signOut() async {
    await authRepository.signOut(AuthType.google);
  }

  Future<String> getDisplayName() async {
    AppUser? user = await authRepository.getCurrentUser();
    return user?.displayName ?? '';
  }
}
