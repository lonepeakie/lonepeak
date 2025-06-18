import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

class TreasuryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _estatesCollection() => _firestore.collection('estates');

  CollectionReference<TreasuryTransaction> _transactionsCollection(
      String estateId) {
    return _estatesCollection()
        .doc(estateId)
        .collection('transactions')
        .withConverter<TreasuryTransaction>(
          fromFirestore: (snapshot, _) =>
              TreasuryTransaction.fromJson(snapshot.data()!, id: snapshot.id),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
  }

  Future<Result<List<TreasuryTransaction>>> getTransactions(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    bool? isIncome,
  }) async {
    try {
      Query<TreasuryTransaction> query = _transactionsCollection(estateId);

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        );
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (isIncome != null) {
        query = query.where('isIncome', isEqualTo: isIncome);
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      final transactions = snapshot.docs.map((doc) => doc.data()).toList();
      return Result.success(transactions);
    } catch (e, stackTrace) {
      debugPrint('Error fetching transactions: $e\n$stackTrace');
      return Result.failure(
          'Error fetching transactions. Check logs for details.');
    }
  }

  Future<Result<void>> addTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    try {
      final batch = _firestore.batch();
      final newDocRef = _transactionsCollection(estateId).doc();
      batch.set(newDocRef, transaction);

      final amountToAdd =
          transaction.isIncome ? transaction.amount : -transaction.amount;
      final estateRef = _estatesCollection().doc(estateId);
      batch.update(
          estateRef, {'currentBalance': FieldValue.increment(amountToAdd)});

      await batch.commit();
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('Error adding transaction: $e\n$stackTrace');
      return Result.failure('Error adding transaction.');
    }
  }

  Future<Result<void>> updateTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    final originalTransactionResult =
        await getTransactionById(estateId, transaction.id!);
    if (originalTransactionResult.isFailure) {
      return Result.failure('Could not find original transaction to update.');
    }
    // CORRECTED: Using .data instead of .value
    final originalTransaction = originalTransactionResult.data!;

    try {
      final batch = _firestore.batch();
      final estateRef = _estatesCollection().doc(estateId);
      final transactionRef =
          _transactionsCollection(estateId).doc(transaction.id);

      final originalAmount = originalTransaction.isIncome
          ? originalTransaction.amount
          : -originalTransaction.amount;
      final newAmount =
          transaction.isIncome ? transaction.amount : -transaction.amount;
      final balanceChange = newAmount - originalAmount;

      batch.update(
          estateRef, {'currentBalance': FieldValue.increment(balanceChange)});
      batch.set(transactionRef, transaction);

      await batch.commit();
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('Error updating transaction: $e\n$stackTrace');
      return Result.failure('Error updating transaction.');
    }
  }

  Future<Result<void>> deleteTransaction(
    String estateId,
    String transactionId,
  ) async {
    final transactionToDeleteResult =
        await getTransactionById(estateId, transactionId);
    if (transactionToDeleteResult.isFailure) {
      return Result.failure('Could not find transaction to delete.');
    }
    // CORRECTED: Using .data instead of .value
    final transactionToDelete = transactionToDeleteResult.data!;

    try {
      final batch = _firestore.batch();
      final docRef = _transactionsCollection(estateId).doc(transactionId);
      batch.delete(docRef);

      final amountToReverse = transactionToDelete.isIncome
          ? -transactionToDelete.amount
          : transactionToDelete.amount;
      final estateRef = _estatesCollection().doc(estateId);
      batch.update(
          estateRef, {'currentBalance': FieldValue.increment(amountToReverse)});

      await batch.commit();
      return Result.success(null);
    } catch (e, stackTrace) {
      debugPrint('Error deleting transaction: $e\n$stackTrace');
      return Result.failure('Error deleting transaction.');
    }
  }

  Future<Result<TreasuryTransaction>> getTransactionById(
    String estateId,
    String transactionId,
  ) async {
    try {
      final doc =
          await _transactionsCollection(estateId).doc(transactionId).get();
      if (!doc.exists) {
        return Result.failure('Transaction not found');
      }
      return Result.success(doc.data()!);
    } catch (e, stackTrace) {
      debugPrint('Error getting transaction by ID: $e\n$stackTrace');
      return Result.failure('Error getting transaction by ID.');
    }
  }

  Future<Result<double>> getCurrentBalance(String estateId) async {
    try {
      final doc = await _estatesCollection().doc(estateId).get();
      if (!doc.exists) {
        return Result.failure('Estate document not found.');
      }
      final data = doc.data() as Map<String, dynamic>?;
      final balance = (data?['currentBalance'] as num?)?.toDouble() ?? 0.0;
      return Result.success(balance);
    } catch (e, stackTrace) {
      debugPrint('Error getting current balance: $e\n$stackTrace');
      return Result.failure('Error getting current balance.');
    }
  }

  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
    bool isIncome = false,
  }) async {
    try {
      final transactionsResult = await getTransactions(
        estateId,
        startDate: startDate,
        endDate: endDate,
        isIncome: isIncome,
      );

      if (transactionsResult.isFailure) {
        return Result.failure('Could not fetch transactions for summary.');
      }

      final summary = <TransactionType, double>{};

      // CORRECTED: Using .data instead of .value
      for (final transaction in transactionsResult.data!) {
        summary.update(
          transaction.type,
          (existingValue) => existingValue + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }

      return Result.success(summary);
    } catch (e, stackTrace) {
      debugPrint('Error getting transaction summary: $e\n$stackTrace');
      return Result.failure('Error creating transaction summary.');
    }
  }
}
