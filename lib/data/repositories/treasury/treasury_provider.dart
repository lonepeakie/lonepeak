import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository_firestore.dart';
import 'package:lonepeak/data/services/treasury/treasury_service.dart';

final treasuryServiceProvider = Provider<TreasuryService>((ref) {
  return TreasuryService();
});

final treasuryRepositoryProvider = Provider<TreasuryRepository>((ref) {
  final treasuryService = ref.watch(treasuryServiceProvider);
  return TreasuryRepositoryFirestore(
    treasuryService: treasuryService,
  );
});
