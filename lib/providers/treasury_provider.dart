import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository_firestore.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';

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
    loadTransactions();
  }

  final TreasuryRepository _repository;
  List<TreasuryTransaction> _cachedTransactions = [];
  double _cachedBalance = 0.0;

  /// Get cached transactions (synchronous)
  List<TreasuryTransaction> get cachedTransactions => _cachedTransactions;
  double get cachedBalance => _cachedBalance;

  /// Load all transactions and current balance
  Future<void> loadTransactions() async {
    state = state.copyWith(
      transactions: const AsyncValue.loading(),
      currentBalance: const AsyncValue.loading(),
    );

    try {
      // Load transactions
      final transactionsResult = await _repository.getTransactions();
      if (transactionsResult.isFailure) {
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

      _cachedTransactions = transactionsResult.data ?? [];

      // Load current balance
      final balanceResult = await _repository.getCurrentBalance();
      if (balanceResult.isFailure) {
        state = state.copyWith(
          currentBalance: AsyncValue.error(
            Exception('Failed to load balance: ${balanceResult.error}'),
            StackTrace.current,
          ),
        );
        return;
      }

      _cachedBalance = balanceResult.data ?? 0.0;

      // Apply current filters if any
      if (state.filters.hasAnyFilter) {
        await _applyFiltersToTransactions();
      } else {
        state = state.copyWith(
          transactions: AsyncValue.data([..._cachedTransactions]),
          currentBalance: AsyncValue.data(_cachedBalance),
        );
      }
    } catch (error, stackTrace) {
      state = state.copyWith(
        transactions: AsyncValue.error(error, stackTrace),
        currentBalance: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Add a new transaction
  Future<void> addTransaction(TreasuryTransaction transaction) async {
    try {
      final result = await _repository.addTransaction(transaction);

      if (result.isFailure) {
        throw Exception('Failed to add transaction: ${result.error}');
      }

      // Add to cached list and update balance
      _cachedTransactions.add(transaction);
      if (transaction.isIncome) {
        _cachedBalance += transaction.amount;
      } else {
        _cachedBalance -= transaction.amount;
      }

      // Reapply filters if needed
      if (state.filters.hasAnyFilter) {
        await _applyFiltersToTransactions();
      } else {
        state = state.copyWith(
          transactions: AsyncValue.data([..._cachedTransactions]),
          currentBalance: AsyncValue.data(_cachedBalance),
        );
      }
    } catch (error) {
      throw error;
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(TreasuryTransaction transaction) async {
    try {
      final result = await _repository.updateTransaction(transaction);

      if (result.isFailure) {
        throw Exception('Failed to update transaction: ${result.error}');
      }

      // Update in cached list
      final index = _cachedTransactions.indexWhere(
        (t) => t.id == transaction.id,
      );
      if (index != -1) {
        final oldTransaction = _cachedTransactions[index];
        _cachedTransactions[index] = transaction;

        // Update balance calculation
        if (oldTransaction.isIncome) {
          _cachedBalance -= oldTransaction.amount;
        } else {
          _cachedBalance += oldTransaction.amount;
        }

        if (transaction.isIncome) {
          _cachedBalance += transaction.amount;
        } else {
          _cachedBalance -= transaction.amount;
        }
      }

      // Reapply filters if needed
      if (state.filters.hasAnyFilter) {
        await _applyFiltersToTransactions();
      } else {
        state = state.copyWith(
          transactions: AsyncValue.data([..._cachedTransactions]),
          currentBalance: AsyncValue.data(_cachedBalance),
        );
      }
    } catch (error) {
      throw error;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final result = await _repository.deleteTransaction(transactionId);

      if (result.isFailure) {
        throw Exception('Failed to delete transaction: ${result.error}');
      }

      // Remove from cached list and update balance
      final transactionIndex = _cachedTransactions.indexWhere(
        (t) => t.id == transactionId,
      );
      if (transactionIndex != -1) {
        final transaction = _cachedTransactions[transactionIndex];
        _cachedTransactions.removeAt(transactionIndex);

        if (transaction.isIncome) {
          _cachedBalance -= transaction.amount;
        } else {
          _cachedBalance += transaction.amount;
        }
      }

      // Reapply filters if needed
      if (state.filters.hasAnyFilter) {
        await _applyFiltersToTransactions();
      } else {
        state = state.copyWith(
          transactions: AsyncValue.data([..._cachedTransactions]),
          currentBalance: AsyncValue.data(_cachedBalance),
        );
      }
    } catch (error) {
      throw error;
    }
  }

  /// Apply transaction filters
  Future<void> applyFilters(TransactionFilters newFilters) async {
    state = state.copyWith(filters: newFilters);

    if (newFilters.hasAnyFilter) {
      await _applyFiltersToTransactions();
    } else {
      // Show all cached transactions
      state = state.copyWith(
        transactions: AsyncValue.data([..._cachedTransactions]),
      );
    }
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    await applyFilters(const TransactionFilters());
  }

  /// Apply current filters to transactions
  Future<void> _applyFiltersToTransactions() async {
    final currentFilters = state.filters;

    try {
      // Get filtered transactions from repository if date filters are applied
      List<TreasuryTransaction> filteredTransactions;

      if (currentFilters.startDate != null || currentFilters.endDate != null) {
        final result = await _repository.getTransactionsBetweenDates(
          startDate: currentFilters.startDate,
          endDate: currentFilters.endDate,
        );

        if (result.isFailure) {
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
        filteredTransactions = [..._cachedTransactions];
      }

      // Apply income/expense filter
      if (currentFilters.isIncome != null) {
        filteredTransactions =
            filteredTransactions
                .where((trx) => trx.isIncome == currentFilters.isIncome)
                .toList();
      }

      state = state.copyWith(
        transactions: AsyncValue.data(filteredTransactions),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(transactions: AsyncValue.error(error, stackTrace));
    }
  }

  /// Refresh all treasury data
  Future<void> refreshTreasury() async {
    _cachedTransactions.clear();
    _cachedBalance = 0.0;
    await loadTransactions();
  }

  /// Clear all cached data
  void clearCache() {
    _cachedTransactions.clear();
    _cachedBalance = 0.0;
    state = const TreasuryState();
  }

  /// Get transactions by type (income/expense)
  List<TreasuryTransaction> getTransactionsByType(bool isIncome) {
    return _cachedTransactions.where((t) => t.isIncome == isIncome).toList();
  }

  /// Get total amount for a specific type
  double getTotalByType(bool isIncome) {
    return _cachedTransactions
        .where((t) => t.isIncome == isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get transactions for a specific date range
  List<TreasuryTransaction> getTransactionsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _cachedTransactions
        .where(
          (t) =>
              t.date.isAfter(start.subtract(const Duration(days: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }
}
