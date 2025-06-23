import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/utils/result.dart';
import 'package:logger/logger.dart';

final treasuryServiceProvider = Provider<TreasuryService>(
  (ref) => TreasuryService(),
);

class TreasuryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _log = Logger(printer: PrefixedLogPrinter('TreasuryService'));

  Future<Result<void>> addTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      return Result.failure('Transaction ID is required for creation');
    }

    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter(
          fromFirestore:
              (snapshot, _) => TreasuryTransaction.fromJson(
                snapshot.data()!,
                id: snapshot.id,
              ),
          toFirestore: (transaction, _) => transaction.toJson(),
        )
        .doc(transaction.id);

    try {
      await docRef.set(transaction);
      _log.i('Transaction added successfully with ID: ${transaction.id}');
      return Result.success(null);
    } catch (e) {
      _log.e('Failed to add transaction: $e');
      return Result.failure('Failed to add transaction');
    }
  }

  Future<Result<TreasuryTransaction>> getTransaction(
    String estateId,
    String transactionId,
  ) async {
    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter(
          fromFirestore:
              (snapshot, _) => TreasuryTransaction.fromJson(
                snapshot.data()!,
                id: snapshot.id,
              ),
          toFirestore: (transaction, _) => transaction.toJson(),
        )
        .doc(transactionId);

    try {
      final doc = await docRef.get();
      if (doc.exists) {
        return Result.success(doc.data()!);
      } else {
        return Result.failure('Transaction not found');
      }
    } catch (e) {
      _log.e('Failed to get transaction: $e');
      return Result.failure('Failed to get transaction');
    }
  }

  Future<Result<void>> updateTransaction(
    String estateId,
    TreasuryTransaction transaction,
  ) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      return Result.failure('Transaction ID is required for update');
    }

    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter(
          fromFirestore:
              (snapshot, _) => TreasuryTransaction.fromJson(
                snapshot.data()!,
                id: snapshot.id,
              ),
          toFirestore: (transaction, _) => transaction.toJson(),
        )
        .doc(transaction.id);

    try {
      await docRef.set(transaction);
      _log.i('Transaction updated successfully');
      return Result.success(null);
    } catch (e) {
      _log.e('Failed to update transaction: $e');
      return Result.failure('Failed to update transaction');
    }
  }

  Future<Result<void>> deleteTransaction(
    String estateId,
    String transactionId,
  ) async {
    final docRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter(
          fromFirestore:
              (snapshot, _) => TreasuryTransaction.fromJson(
                snapshot.data()!,
                id: snapshot.id,
              ),
          toFirestore: (transaction, _) => transaction.toJson(),
        )
        .doc(transactionId);

    try {
      await docRef.delete();
      _log.i('Transaction deleted: $transactionId');
      return Result.success(null);
    } catch (e) {
      _log.e('Failed to delete transaction: $e');
      return Result.failure('Failed to delete transaction');
    }
  }

  Future<Result<List<TreasuryTransaction>>> getTransactions(
    String estateId,
  ) async {
    final collectionRef = _db
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter(
          fromFirestore:
              (snapshot, _) => TreasuryTransaction.fromJson(
                snapshot.data()!,
                id: snapshot.id,
              ),
          toFirestore: (transaction, _) => transaction.toJson(),
        )
        .orderBy('date', descending: true);

    try {
      final snapshot = await collectionRef.get();
      final transactions = snapshot.docs.map((doc) => doc.data()).toList();
      _log.i('Fetched ${transactions.length} transactions');
      return Result.success(transactions);
    } catch (e) {
      _log.e('Failed to fetch transactions: $e');
      return Result.failure('Failed to get transactions');
    }
  }

  Future<Result<double>> getCurrentBalance(String estateId) async {
    final result = await getTransactions(estateId);
    if (result.isFailure) return Result.failure(result.error!);

    final transactions = result.data!;
    double balance = 0;

    for (var tx in transactions) {
      balance += tx.isIncome ? tx.amount : -tx.amount;
    }

    _log.i('Current balance: $balance');
    return Result.success(balance);
  }

  Future<Result<Map<TransactionType, double>>> getTransactionSummaryByType(
    String estateId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<TreasuryTransaction> query = _db
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter(
          fromFirestore:
              (snapshot, _) => TreasuryTransaction.fromJson(
                snapshot.data()!,
                id: snapshot.id,
              ),
          toFirestore: (transaction, _) => transaction.toJson(),
        );

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

    try {
      final snapshot = await query.get();
      final transactions = snapshot.docs.map((doc) => doc.data()).toList();

      final summary = <TransactionType, double>{
        for (var type in TransactionType.values) type: 0,
      };

      for (var tx in transactions) {
        if (!tx.isIncome) {
          summary[tx.type] = (summary[tx.type] ?? 0) + tx.amount;
        }
      }

      _log.i('Summary by type: $summary');
      return Result.success(summary);
    } catch (e) {
      _log.e('Failed to get summary: $e');
      return Result.failure('Failed to get transaction summary');
    }
  }
}
