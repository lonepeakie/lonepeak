import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

abstract class TreasuryRepository {
  Future<Result<List<TreasuryTransaction>>> getTransactions();
  Future<Result<TreasuryTransaction>> getTransactionById(String transactionId);
  Future<Result<void>> addTransaction(TreasuryTransaction transaction);
  Future<Result<void>> updateTransaction(TreasuryTransaction transaction);
  Future<Result<void>> deleteTransaction(String transactionId);
  Future<Result<double>> getCurrentBalance();
  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType({
    DateTime? startDate,
    DateTime? endDate,
  });
}
