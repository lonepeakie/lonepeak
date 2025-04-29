import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/services/treasury/treasury_service.dart';
import 'package:lonepeak/domain/models/metadata.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/utils/result.dart';

class TreasuryRepositoryFirestore extends TreasuryRepository {
  TreasuryRepositoryFirestore({
    required AppState appState,
    required TreasuryService treasuryService,
  }) : _treasuryService = treasuryService,
       _appState = appState;

  final TreasuryService _treasuryService;
  final AppState _appState;

  @override
  Future<Result<void>> addTransaction(TreasuryTransaction transaction) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }

    // Set metadata for new transaction
    transaction.metadata = Metadata(
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    return _treasuryService.addTransaction(estateId, transaction);
  }

  @override
  Future<Result<void>> deleteTransaction(String transactionId) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _treasuryService.deleteTransaction(estateId, transactionId);
  }

  @override
  Future<Result<TreasuryTransaction>> getTransactionById(String transactionId) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _treasuryService.getTransactionById(estateId, transactionId);
  }

  @override
  Future<Result<List<TreasuryTransaction>>> getTransactions() {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _treasuryService.getTransactions(estateId);
  }

  @override
  Future<Result<void>> updateTransaction(TreasuryTransaction transaction) {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }

    // Update metadata for transaction
    if (transaction.metadata != null) {
      transaction.metadata!.updatedAt = Timestamp.now();
    } else {
      transaction.metadata = Metadata(
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
    }

    return _treasuryService.updateTransaction(estateId, transaction);
  }

  @override
  Future<Result<double>> getCurrentBalance() {
    final estateId = _appState.getEstateId;
    if (estateId == null) {
      return Future.value(Result.failure('Estate ID is null'));
    }
    return _treasuryService.getCurrentBalance(estateId);
  }

  @override
  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final estateId = _appState.getEstateId;
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
