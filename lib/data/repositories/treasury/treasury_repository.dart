import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

abstract class TreasuryRepository {
  Future<Result<List<TreasuryTransaction>>> getTransactions(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    bool? isIncome,
  });
  Future<Result<TreasuryTransaction>> getTransactionById(
    String estateId,
    String transactionId,
  );
  Future<Result<void>> addTransaction(
    String estateId,
    TreasuryTransaction transaction,
  );
  Future<Result<void>> updateTransaction(
    String estateId,
    TreasuryTransaction transaction,
  );
  Future<Result<void>> deleteTransaction(
    String estateId,
    String transactionId,
  );
  Future<Result<double>> getCurrentBalance(String estateId);
  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}
