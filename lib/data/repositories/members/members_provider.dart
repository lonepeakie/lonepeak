import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/members/members_repository_firestore.dart';
import 'package:lonepeak/data/services/members/members_service.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final membersRepositoryProvider = Provider<MembersRepositoryFirestore>((ref) {
  return MembersRepositoryFirestore(
    membersService: ref.read(membersServiceProvider),
    appState: ref.read(appStateProvider),
  );
});
