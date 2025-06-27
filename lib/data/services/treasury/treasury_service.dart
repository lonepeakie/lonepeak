import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';

final treasuryServiceProvider = Provider<TreasuryService>((ref) {
  return TreasuryService();
});

class TreasuryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('NoticeService'));

  CollectionReference<TreasuryTransaction> _getTransactionsCollection(
    String estateId,
  ) {
    return _db
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter(
          fromFirestore: TreasuryTransaction.fromFirestore,
          toFirestore:
              (TreasuryTransaction transaction, options) =>
                  transaction.toFirestore(),
        );
  }

  Future<Result<List<TreasuryTransaction>>> getTransactions(
    String estateId,
  ) async {
    try {
      final transactionsRef = _getTransactionsCollection(estateId);
      final snapshot =
          await transactionsRef.orderBy('date', descending: true).get();

      final transactions = snapshot.docs.map((doc) => doc.data()).toList();

      return Result.success(transactions);
    } catch (e) {
      _log.e('Failed to get transactions: $e');
      return Result.failure('Failed to get transactions: ${e.toString()}');
    }
  }

  Future<Result<TreasuryTransaction>> getTransactionById(
    String estateId,
    String transactionId,
  ) async {
    try {
      final transactionDoc =
          await _getTransactionsCollection(estateId).doc(transactionId).get();

      if (!transactionDoc.exists) {
        _log.w('Transaction with ID $transactionId not found');
        return Result.failure('Transaction not found');
      }

      return Result.success(transactionDoc.data()!);
    } catch (e) {
      _log.e('Failed to get transaction: $e');
      return Result.failure('Failed to get transaction: ${e.toString()}');
    }
  }

  Future<Result<void>> addTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    try {
      await _getTransactionsCollection(estateId).add(transaction);
      return Result.success(null);
    } catch (e) {
      _log.e('Failed to add transaction: $e');
      return Result.failure('Failed to add transaction: ${e.toString()}');
    }
  }

  Future<Result<void>> updateTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    try {
      if (transaction.id == null) {
        return Result.failure('Transaction ID cannot be null');
      }

      await _getTransactionsCollection(
        estateId,
      ).doc(transaction.id).update(transaction.toFirestore());
      return Result.success(null);
    } catch (e) {
      _log.e('Failed to update transaction: $e');
      return Result.failure('Failed to update transaction: ${e.toString()}');
    }
  }

  Future<Result<void>> deleteTransaction(
    String estateId,
    String transactionId,
  ) async {
    try {
      await _getTransactionsCollection(estateId).doc(transactionId).delete();
      return Result.success(null);
    } catch (e) {
      _log.e('Failed to delete transaction: $e');
      return Result.failure('Failed to delete transaction: ${e.toString()}');
    }
  }

  Future<Result<double>> getCurrentBalance(String estateId) async {
    try {
      final transactionsResult = await getTransactions(estateId);

      if (transactionsResult.isFailure) {
        return Result.failure(transactionsResult.error!);
      }

      final transactions = transactionsResult.data!;
      double balance = 0;

      for (var transaction in transactions) {
        if (transaction.isIncome) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }

      return Result.success(balance);
    } catch (e) {
      _log.e('Failed to calculate balance: $e');
      return Result.failure('Failed to calculate balance: ${e.toString()}');
    }
  }

  Future<Result<List<TreasuryTransaction>>> getTransactionsBetweenDates(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collection('estates')
          .doc(estateId)
          .collection('transactions');

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final transactions =
          snapshot.docs
              .map((doc) => TreasuryTransaction.fromFirestore(doc, null))
              .toList();

      return Result.success(transactions);
    } catch (e) {
      _log.e('Failed to get transactions between dates: $e');
      return Result.failure(
        'Failed to get transactions between dates: ${e.toString()}',
      );
    }
  }
}
