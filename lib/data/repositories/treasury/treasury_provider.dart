import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository_firestore.dart';
import 'package:lonepeak/data/services/treasury/treasury_service.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final treasuryServiceProvider = Provider<TreasuryService>((ref) {
  return TreasuryService();
});

final treasuryRepositoryProvider = Provider<TreasuryRepository>((ref) {
  final appState = ref.watch(appStateProvider);
  final treasuryService = ref.watch(treasuryServiceProvider);

  return TreasuryRepositoryFirestore(
    appState: appState,
    treasuryService: treasuryService,
  );
});
