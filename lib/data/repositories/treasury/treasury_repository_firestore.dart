import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/services/treasury/treasury_service.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

final treasuryRepositoryProvider = Provider<TreasuryRepository>((ref) {
  final appState = ref.watch(appStateProvider);
  final treasuryService = ref.watch(treasuryServiceProvider);

  return TreasuryRepositoryFirestore(
    appState: appState,
    treasuryService: treasuryService,
  );
});

class TreasuryRepositoryFirestore extends TreasuryRepository {
  TreasuryRepositoryFirestore({
    required AppState appState,
    required TreasuryService treasuryService,
  }) : _treasuryService = treasuryService,
       _appState = appState;

  final TreasuryService _treasuryService;
  final AppState _appState;

  @override
  Future<Result<void>> addTransaction(TreasuryTransaction transaction) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final updatedTransactiion = transaction.copyWith(
      metadata: Metadata(createdAt: Timestamp.now(), createdBy: userEmail),
    );

    return _treasuryService.addTransaction(estateId, updatedTransactiion);
  }

  @override
  Future<Result<void>> deleteTransaction(String transactionId) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _treasuryService.deleteTransaction(estateId, transactionId);
  }

  @override
  Future<Result<TreasuryTransaction>> getTransactionById(
    String transactionId,
  ) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _treasuryService.getTransactionById(estateId, transactionId);
  }

  @override
  Future<Result<List<TreasuryTransaction>>> getTransactions() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }
    return _treasuryService.getTransactions(estateId);
  }

  @override
  Future<Result<void>> updateTransaction(
    TreasuryTransaction transaction,
  ) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Result.failure('Estate ID is null');
    }

    final userEmail = _appState.getUserId();
    final updatedTransaction = transaction.copyWith(
      metadata: transaction.metadata?.copyWith(
        updatedAt: Timestamp.now(),
        updatedBy: userEmail,
      ),
    );

    return _treasuryService.updateTransaction(estateId, updatedTransaction);
  }

  @override
  Future<Result<double>> getCurrentBalance() async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _treasuryService.getCurrentBalance(estateId);
  }

  @override
  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final estateId = await _appState.getEstateId();
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _treasuryService.getTransactionSummaryByType(
      estateId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
