import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository_firestore.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/log_printer.dart';

/// Transaction filters for treasury data
class TransactionFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isIncome;

  const TransactionFilters({this.startDate, this.endDate, this.isIncome});

  TransactionFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
  }) {
    return TransactionFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  bool get hasAnyFilter =>
      startDate != null || endDate != null || isIncome != null;

  bool get isClear => !hasAnyFilter;
}

/// Treasury state with AsyncValue pattern
class TreasuryState {
  final AsyncValue<List<TreasuryTransaction>> transactions;
  final AsyncValue<double> currentBalance;
  final TransactionFilters filters;

  const TreasuryState({
    this.transactions = const AsyncValue.data([]),
    this.currentBalance = const AsyncValue.data(0.0),
    this.filters = const TransactionFilters(),
  });

  TreasuryState copyWith({
    AsyncValue<List<TreasuryTransaction>>? transactions,
    AsyncValue<double>? currentBalance,
    TransactionFilters? filters,
  }) {
    return TreasuryState(
      transactions: transactions ?? this.transactions,
      currentBalance: currentBalance ?? this.currentBalance,
      filters: filters ?? this.filters,
    );
  }
}

/// Provider for treasury management with caching
final treasuryProvider = StateNotifierProvider<TreasuryProvider, TreasuryState>(
  (ref) {
    final repository = ref.watch(treasuryRepositoryProvider);
    return TreasuryProvider(repository);
  },
);

/// Provider for current balance
final currentBalanceProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(treasuryRepositoryProvider);
  final result = await repository.getCurrentBalance();

  if (result.isFailure) {
    throw Exception('Failed to fetch current balance: ${result.error}');
  }

  return result.data ?? 0.0;
});

/// Provider for income/expense summary
final treasurySummaryProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  final repository = ref.watch(treasuryRepositoryProvider);
  final result = await repository.getTransactions();

  if (result.isFailure) {
    throw Exception('Failed to fetch transactions: ${result.error}');
  }

  final transactions = result.data ?? [];
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  for (final transaction in transactions) {
    if (transaction.isIncome) {
      totalIncome += transaction.amount;
    } else {
      totalExpense += transaction.amount;
    }
  }

  return {
    'income': totalIncome,
    'expense': totalExpense,
    'balance': totalIncome - totalExpense,
  };
});

class TreasuryProvider extends StateNotifier<TreasuryState> {
  TreasuryProvider(this._repository) : super(const TreasuryState()) {
    _loadTransactions();
  }

  final TreasuryRepository _repository;
  final _log = Logger(printer: PrefixedLogPrinter('TreasuryProvider'));

  /// Get current transactions from state
  List<TreasuryTransaction> get transactions => state.transactions.value ?? [];

  /// Get current balance from state
  double get balance => state.currentBalance.value ?? 0.0;

  Future<void> _loadTransactions() async {
    await loadTransactions();
  }

  void ensureDataLoaded() {
    if (state.transactions is! AsyncLoading &&
        (!state.transactions.hasValue ||
            state.transactions.value?.isEmpty == true)) {
      _loadTransactions();
    }
  }

  /// Load all transactions and current balance
  Future<void> loadTransactions() async {
    if (state.transactions.hasValue &&
        state.transactions.value?.isNotEmpty == true &&
        state.transactions is! AsyncError) {
      _log.i(
        'Using existing transaction data (${state.transactions.value?.length ?? 0} transactions)',
      );
      return;
    }

    if (state.transactions is! AsyncLoading) {
      state = state.copyWith(
        transactions: const AsyncValue.loading(),
        currentBalance: const AsyncValue.loading(),
      );
    }

    try {
      _log.i('Fetching transactions from repository');
      // Load transactions
      final transactionsResult = await _repository.getTransactions();
      if (transactionsResult.isFailure) {
        _log.e('Failed to load transactions: ${transactionsResult.error}');
        state = state.copyWith(
          transactions: AsyncValue.error(
            Exception(
              'Failed to load transactions: ${transactionsResult.error}',
            ),
            StackTrace.current,
          ),
        );
        return;
      }

      final transactions = transactionsResult.data ?? [];
      _log.i('Successfully fetched ${transactions.length} transactions');

      // Load current balance
      final balanceResult = await _repository.getCurrentBalance();
      if (balanceResult.isFailure) {
        _log.e('Failed to load balance: ${balanceResult.error}');
        state = state.copyWith(
          currentBalance: AsyncValue.error(
            Exception('Failed to load balance: ${balanceResult.error}'),
            StackTrace.current,
          ),
        );
        return;
      }

      final balance = balanceResult.data ?? 0.0;
      _log.i('Successfully fetched balance: \$${balance.toStringAsFixed(2)}');

      // Apply current filters if any
      if (state.filters.hasAnyFilter) {
        await _applyFiltersToTransactions(transactions);
      } else {
        state = state.copyWith(
          transactions: AsyncValue.data(transactions),
          currentBalance: AsyncValue.data(balance),
        );
      }
    } catch (error, stackTrace) {
      _log.e(
        'Error loading transactions: $error',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        transactions: AsyncValue.error(error, stackTrace),
        currentBalance: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Add a new transaction
  Future<void> addTransaction(TreasuryTransaction transaction) async {
    try {
      _log.i('Adding new transaction: ${transaction.description}');
      final result = await _repository.addTransaction(transaction);

      if (result.isFailure) {
        _log.e('Failed to add transaction: ${result.error}');
        throw Exception('Failed to add transaction: ${result.error}');
      }

      // Get current transactions and balance from state
      final currentTransactions = state.transactions.value ?? [];
      final currentBalance = state.currentBalance.value ?? 0.0;

      // Add to transaction list and update balance
      final updatedTransactions = [...currentTransactions, transaction];
      final updatedBalance =
          transaction.isIncome
              ? currentBalance + transaction.amount
              : currentBalance - transaction.amount;

      _log.i(
        'Successfully added transaction, new balance: \$${updatedBalance.toStringAsFixed(2)}',
      );

      // Reapply filters if needed
      if (state.filters.hasAnyFilter) {
        await _applyFiltersToTransactions(updatedTransactions);
      } else {
        state = state.copyWith(
          transactions: AsyncValue.data(updatedTransactions),
          currentBalance: AsyncValue.data(updatedBalance),
        );
      }
    } catch (error) {
      _log.e('Error adding transaction: $error');
      rethrow;
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(TreasuryTransaction transaction) async {
    try {
      _log.i('Updating transaction: ${transaction.description}');
      final result = await _repository.updateTransaction(transaction);

      if (result.isFailure) {
        _log.e('Failed to update transaction: ${result.error}');
        throw Exception('Failed to update transaction: ${result.error}');
      }

      // Get current transactions and balance from state
      final currentTransactions = List<TreasuryTransaction>.from(
        state.transactions.value ?? [],
      );
      final currentBalance = state.currentBalance.value ?? 0.0;

      // Update in transaction list
      final index = currentTransactions.indexWhere(
        (t) => t.id == transaction.id,
      );
      if (index != -1) {
        final oldTransaction = currentTransactions[index];
        currentTransactions[index] = transaction;

        // Update balance calculation
        var updatedBalance = currentBalance;

        // Remove old transaction's effect on balance
        if (oldTransaction.isIncome) {
          updatedBalance -= oldTransaction.amount;
        } else {
          updatedBalance += oldTransaction.amount;
        }

        // Add new transaction's effect on balance
        if (transaction.isIncome) {
          updatedBalance += transaction.amount;
        } else {
          updatedBalance -= transaction.amount;
        }

        _log.i(
          'Successfully updated transaction, new balance: \$${updatedBalance.toStringAsFixed(2)}',
        );

        // Reapply filters if needed
        if (state.filters.hasAnyFilter) {
          await _applyFiltersToTransactions(currentTransactions);
        } else {
          state = state.copyWith(
            transactions: AsyncValue.data(currentTransactions),
            currentBalance: AsyncValue.data(updatedBalance),
          );
        }
      }
    } catch (error) {
      _log.e('Error updating transaction: $error');
      rethrow;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      _log.i('Deleting transaction: $transactionId');
      final result = await _repository.deleteTransaction(transactionId);

      if (result.isFailure) {
        _log.e('Failed to delete transaction: ${result.error}');
        throw Exception('Failed to delete transaction: ${result.error}');
      }

      // Get current transactions and balance from state
      final currentTransactions = List<TreasuryTransaction>.from(
        state.transactions.value ?? [],
      );
      final currentBalance = state.currentBalance.value ?? 0.0;

      // Remove from transaction list and update balance
      final transactionIndex = currentTransactions.indexWhere(
        (t) => t.id == transactionId,
      );
      if (transactionIndex != -1) {
        final transaction = currentTransactions[transactionIndex];
        currentTransactions.removeAt(transactionIndex);

        final updatedBalance =
            transaction.isIncome
                ? currentBalance - transaction.amount
                : currentBalance + transaction.amount;

        _log.i(
          'Successfully deleted transaction, new balance: \$${updatedBalance.toStringAsFixed(2)}',
        );

        // Reapply filters if needed
        if (state.filters.hasAnyFilter) {
          await _applyFiltersToTransactions(currentTransactions);
        } else {
          state = state.copyWith(
            transactions: AsyncValue.data(currentTransactions),
            currentBalance: AsyncValue.data(updatedBalance),
          );
        }
      }
    } catch (error) {
      _log.e('Error deleting transaction: $error');
      rethrow;
    }
  }

  /// Apply transaction filters
  Future<void> applyFilters(TransactionFilters newFilters) async {
    _log.i(
      'Applying filters: ${newFilters.hasAnyFilter ? 'with filters' : 'no filters'}',
    );
    state = state.copyWith(filters: newFilters);

    if (newFilters.hasAnyFilter) {
      await _applyFiltersToTransactions();
    } else {
      // Show all transactions from state
      final allTransactions = await _getAllTransactions();
      state = state.copyWith(transactions: AsyncValue.data(allTransactions));
    }
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    await applyFilters(const TransactionFilters());
  }

  /// Apply current filters to transactions
  Future<void> _applyFiltersToTransactions([
    List<TreasuryTransaction>? transactions,
  ]) async {
    final currentFilters = state.filters;
    final sourceTransactions = transactions ?? await _getAllTransactions();

    try {
      _log.i('Applying filters to ${sourceTransactions.length} transactions');
      // Get filtered transactions from repository if date filters are applied
      List<TreasuryTransaction> filteredTransactions;

      if (currentFilters.startDate != null || currentFilters.endDate != null) {
        final result = await _repository.getTransactionsBetweenDates(
          startDate: currentFilters.startDate,
          endDate: currentFilters.endDate,
        );

        if (result.isFailure) {
          _log.e('Failed to filter transactions: ${result.error}');
          state = state.copyWith(
            transactions: AsyncValue.error(
              Exception('Failed to filter transactions: ${result.error}'),
              StackTrace.current,
            ),
          );
          return;
        }

        filteredTransactions = result.data ?? [];
      } else {
        filteredTransactions = [...sourceTransactions];
      }

      // Apply income/expense filter
      if (currentFilters.isIncome != null) {
        filteredTransactions =
            filteredTransactions
                .where((trx) => trx.isIncome == currentFilters.isIncome)
                .toList();
      }

      _log.i('Filtered to ${filteredTransactions.length} transactions');
      state = state.copyWith(
        transactions: AsyncValue.data(filteredTransactions),
      );
    } catch (error, stackTrace) {
      _log.e('Error applying filters: $error');
      state = state.copyWith(transactions: AsyncValue.error(error, stackTrace));
    }
  }

  /// Get all transactions from repository
  Future<List<TreasuryTransaction>> _getAllTransactions() async {
    final result = await _repository.getTransactions();
    if (result.isFailure) {
      throw Exception('Failed to get transactions: ${result.error}');
    }
    return result.data ?? [];
  }

  /// Refresh all treasury data
  Future<void> refreshTreasury() async {
    _log.i('Refreshing treasury data');
    state = const TreasuryState();
    await loadTransactions();
  }

  /// Clear all cached data
  void clearCache() {
    _log.i('Clearing treasury cache');
    state = const TreasuryState();
  }

  /// Get transactions by type (income/expense)
  List<TreasuryTransaction> getTransactionsByType(bool isIncome) {
    final transactions = state.transactions.value ?? [];
    return transactions.where((t) => t.isIncome == isIncome).toList();
  }

  /// Get total amount for a specific type
  double getTotalByType(bool isIncome) {
    final transactions = state.transactions.value ?? [];
    return transactions
        .where((t) => t.isIncome == isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get transactions for a specific date range
  List<TreasuryTransaction> getTransactionsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    final transactions = state.transactions.value ?? [];
    return transactions
        .where(
          (t) =>
              t.date.isAfter(start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }
}
