import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

class TreasuryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Result<List<TreasuryTransaction>>> getTransactions(
    String estateId,
  ) async {
    try {
      final transactionsRef = _db
          .collection('estates')
          .doc(estateId)
          .collection('transactions')
          .withConverter(
            fromFirestore: TreasuryTransaction.fromFirestore,
            toFirestore:
                (TreasuryTransaction transaction, _) =>
                    transaction.toFirestore(),
          );

      final snapshot =
          await transactionsRef.orderBy('date', descending: true).get();

      final transactions = snapshot.docs.map((doc) => doc.data()).toList();

      return Result.success(transactions);
    } catch (e) {
      return Result.failure('Failed to get transactions: ${e.toString()}');
    }
  }

  Future<Result<TreasuryTransaction>> getTransactionById(
    String estateId,
    String transactionId,
  ) async {
    try {
      final transactionDoc =
          await _db
              .collection('estates')
              .doc(estateId)
              .collection('transactions')
              .withConverter(
                fromFirestore: TreasuryTransaction.fromFirestore,
                toFirestore:
                    (TreasuryTransaction transaction, _) =>
                        transaction.toFirestore(),
              )
              .doc(transactionId)
              .get();

      if (!transactionDoc.exists) {
        return Result.failure('Transaction not found');
      }

      return Result.success(transactionDoc.data()!);
    } catch (e) {
      return Result.failure('Failed to get transaction: ${e.toString()}');
    }
  }

  Future<Result<void>> addTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    try {
      await _db
          .collection('estates')
          .doc(estateId)
          .collection('transactions')
          .withConverter(
            fromFirestore: TreasuryTransaction.fromFirestore,
            toFirestore:
                (TreasuryTransaction transaction, _) =>
                    transaction.toFirestore(),
          )
          .add(transaction);
      return Result.success(null);
    } catch (e) {
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

      await _db
          .collection('estates')
          .doc(estateId)
          .collection('transactions')
          .withConverter(
            fromFirestore: TreasuryTransaction.fromFirestore,
            toFirestore:
                (TreasuryTransaction transaction, _) =>
                    transaction.toFirestore(),
          )
          .doc(transaction.id)
          .update(transaction.toFirestore());
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update transaction: ${e.toString()}');
    }
  }

  Future<Result<void>> deleteTransaction(
    String estateId,
    String transactionId,
  ) async {
    try {
      await _db
          .collection('estates')
          .doc(estateId)
          .collection('transactions')
          .withConverter(
            fromFirestore: TreasuryTransaction.fromFirestore,
            toFirestore:
                (TreasuryTransaction transaction, _) =>
                    transaction.toFirestore(),
          )
          .doc(transactionId)
          .delete();
      return Result.success(null);
    } catch (e) {
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
      return Result.failure('Failed to calculate balance: ${e.toString()}');
    }
  }

  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType(
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

      final summary = <TransactionType, double>{};

      for (var type in TransactionType.values) {
        summary[type] = 0;
      }

      for (var transaction in transactions) {
        if (!transaction.isIncome) {
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
