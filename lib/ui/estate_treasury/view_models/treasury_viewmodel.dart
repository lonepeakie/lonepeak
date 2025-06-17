// lib/ui/estate_treasury/view_models/treasury_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_provider.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

final treasuryViewModelProvider =
    StateNotifierProvider.family<TreasuryViewModel, TreasuryState, String>(
        (ref, estateId) {
  final treasuryRepository = ref.watch(treasuryRepositoryProvider);
  return TreasuryViewModel(
    treasuryRepository: treasuryRepository,
    estateId: estateId,
  );
});

class TransactionFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;
  final bool? isIncome;

  const TransactionFilters({
    this.startDate,
    this.endDate,
    this.type,
    this.isIncome,
  });

  bool get isClear =>
      startDate == null && endDate == null && type == null && isIncome == null;

  TransactionFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    bool? isIncome,
  }) {
    return TransactionFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}

class TreasuryState {
  final bool isLoading;
  final String? errorMessage;
  final List<TreasuryTransaction> transactions;
  final double currentBalance;
  final Map<TransactionType, double> expensesByType;
  final TransactionFilters filters;

  TreasuryState({
    this.isLoading = false,
    this.errorMessage,
    this.transactions = const [],
    this.currentBalance = 0.0,
    this.expensesByType = const {},
    this.filters = const TransactionFilters(),
  });

  TreasuryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TreasuryTransaction>? transactions,
    double? currentBalance,
    Map<TransactionType, double>? expensesByType,
    TransactionFilters? filters,
  }) {
    return TreasuryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      transactions: transactions ?? this.transactions,
      currentBalance: currentBalance ?? this.currentBalance,
      expensesByType: expensesByType ?? this.expensesByType,
      filters: filters ?? this.filters,
    );
  }
}

class TreasuryViewModel extends StateNotifier<TreasuryState> {
  TreasuryViewModel({
    required TreasuryRepository treasuryRepository,
    required this.estateId,
  })  : _treasuryRepository = treasuryRepository,
        super(TreasuryState());

  final TreasuryRepository _treasuryRepository;
  final String estateId;

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final transactionsResult = await _treasuryRepository.getTransactions(
      estateId,
      startDate: state.filters.startDate,
      endDate: state.filters.endDate,
      type: state.filters.type,
      isIncome: state.filters.isIncome,
    );
    if (transactionsResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: transactionsResult.error,
      );
      return;
    }

    final balanceResult = await _treasuryRepository.getCurrentBalance(estateId);
    if (balanceResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: balanceResult.error,
      );
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDayOfMonth = DateTime(
      now.year,
      now.month + 1,
      0,
      23,
      59,
      59,
    );
    final expensesResult =
        await _treasuryRepository.getTransactionSummaryByType(
      estateId,
      startDate: firstDayOfMonth,
      endDate: lastDayOfMonth,
    );

    if (expensesResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: expensesResult.error,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      transactions: transactionsResult.data,
      currentBalance: balanceResult.data,
      expensesByType: expensesResult.data,
    );
  }

  Future<void> applyFilters(TransactionFilters newFilters) async {
    state = state.copyWith(filters: newFilters);
    await loadTransactions();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filters: const TransactionFilters());
    await loadTransactions();
  }

  Future<Result<void>> addTransaction(TreasuryTransaction transaction) async {
    final result =
        await _treasuryRepository.addTransaction(estateId, transaction);
    if (result.isSuccess) {
      await loadTransactions();
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
    }
    return result;
  }

  Future<Result<void>> updateTransaction(
    TreasuryTransaction transaction,
  ) async {
    final result =
        await _treasuryRepository.updateTransaction(estateId, transaction);
    if (result.isSuccess) {
      await loadTransactions();
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
    }
    return result;
  }

  Future<Result<void>> deleteTransaction(String transactionId) async {
    final result =
        await _treasuryRepository.deleteTransaction(estateId, transactionId);
    if (result.isSuccess) {
      await loadTransactions();
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
    }
    return result;
  }
}
