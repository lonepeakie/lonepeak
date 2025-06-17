// lib/data/repositories/treasury/treasury_repository_firestore.dart

import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/services/treasury/treasury_service.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

class TreasuryRepositoryFirestore implements TreasuryRepository {
  final TreasuryService _treasuryService;

  TreasuryRepositoryFirestore({required TreasuryService treasuryService})
      : _treasuryService = treasuryService;

  @override
  Future<Result<void>> addTransaction(
      String estateId, TreasuryTransaction transaction) {
    return _treasuryService.addTransaction(estateId, transaction);
  }

  @override
  Future<Result<void>> deleteTransaction(
      String estateId, String transactionId) {
    return _treasuryService.deleteTransaction(estateId, transactionId);
  }

  @override
  Future<Result<double>> getCurrentBalance(String estateId) {
    return _treasuryService.getCurrentBalance(estateId);
  }

  @override
  Future<Result<TreasuryTransaction>> getTransactionById(
      String estateId, String transactionId) {
    return _treasuryService.getTransactionById(estateId, transactionId);
  }

  @override
  Future<Result<List<TreasuryTransaction>>> getTransactions(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    bool? isIncome,
  }) {
    return _treasuryService.getTransactions(
      estateId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      isIncome: isIncome,
    );
  }

  @override
  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _treasuryService.getTransactionSummaryByType(
      estateId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Result<void>> updateTransaction(
      String estateId, TreasuryTransaction transaction) {
    return _treasuryService.updateTransaction(estateId, transaction);
  }
}
