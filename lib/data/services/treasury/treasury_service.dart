import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

class TreasuryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> _getTransactionsCollection(
    String estateId,
  ) {
    return _db.collection('estates').doc(estateId).collection('transactions');
  }

  // Get all transactions for an estate
  Future<Result<List<TreasuryTransaction>>> getTransactions(
    String estateId,
  ) async {
    try {
      final transactionsRef = _getTransactionsCollection(estateId);
      final snapshot =
          await transactionsRef.orderBy('date', descending: true).get();

      final transactions =
          snapshot.docs
              .map((doc) => TreasuryTransaction.fromFirestore(doc, null))
              .toList();

      return Result.success(transactions);
    } catch (e) {
      return Result.failure('Failed to get transactions: ${e.toString()}');
    }
  }

  // Get a transaction by ID
  Future<Result<TreasuryTransaction>> getTransactionById(
    String estateId,
    String transactionId,
  ) async {
    try {
      final transactionDoc =
          await _getTransactionsCollection(estateId).doc(transactionId).get();

      if (!transactionDoc.exists) {
        return Result.failure('Transaction not found');
      }

      return Result.success(
        TreasuryTransaction.fromFirestore(transactionDoc, null),
      );
    } catch (e) {
      return Result.failure('Failed to get transaction: ${e.toString()}');
    }
  }

  // Add a transaction
  Future<Result<void>> addTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    try {
      await _getTransactionsCollection(estateId).add(transaction.toFirestore());
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to add transaction: ${e.toString()}');
    }
  }

  // Update a transaction
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
      return Result.failure('Failed to update transaction: ${e.toString()}');
    }
  }

  // Delete a transaction
  Future<Result<void>> deleteTransaction(
    String estateId,
    String transactionId,
  ) async {
    try {
      await _getTransactionsCollection(estateId).doc(transactionId).delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete transaction: ${e.toString()}');
    }
  }

  // Get the current balance
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
      return Result.failure('Failed to calculate balance: ${e.toString()}');
    }
  }

  // Get transaction summary by type
  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _getTransactionsCollection(estateId);

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

      final summary = <TransactionType, double>{};

      // Initialize all transaction types to 0
      for (var type in TransactionType.values) {
        summary[type] = 0;
      }

      // Sum the amounts by type
      for (var transaction in transactions) {
        if (!transaction.isIncome) {
          // Only count expenses for the summary
          summary[transaction.type] =
              (summary[transaction.type] ?? 0) + transaction.amount;
        }
      }

      return Result.success(summary);
    } catch (e) {
      return Result.failure(
        'Failed to get transaction summary: ${e.toString()}',
      );
    }
  }
}
