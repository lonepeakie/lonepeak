import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository_firestore.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

final treasuryViewModelProvider =
    StateNotifierProvider<TreasuryViewModel, TreasuryState>((ref) {
      final treasuryRepository = ref.watch(treasuryRepositoryProvider);
      return TreasuryViewModel(treasuryRepository: treasuryRepository);
    });

class TreasuryState {
  final bool isLoading;
  final String? errorMessage;
  final List<TreasuryTransaction> transactions;
  final double currentBalance;
  final Map<TransactionType, double> expensesByType;

  TreasuryState({
    this.isLoading = false,
    this.errorMessage,
    this.transactions = const [],
    this.currentBalance = 0.0,
    this.expensesByType = const {},
  });

  TreasuryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TreasuryTransaction>? transactions,
    double? currentBalance,
    Map<TransactionType, double>? expensesByType,
  }) {
    return TreasuryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      transactions: transactions ?? this.transactions,
      currentBalance: currentBalance ?? this.currentBalance,
      expensesByType: expensesByType ?? this.expensesByType,
    );
  }
}

class TreasuryViewModel extends StateNotifier<TreasuryState> {
  TreasuryViewModel({required TreasuryRepository treasuryRepository})
    : _treasuryRepository = treasuryRepository,
      super(TreasuryState());

  final TreasuryRepository _treasuryRepository;

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Load transactions
    final transactionsResult = await _treasuryRepository.getTransactions();
    if (transactionsResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: transactionsResult.error,
      );
      return;
    }

    // Load current balance
    final balanceResult = await _treasuryRepository.getCurrentBalance();
    if (balanceResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: balanceResult.error,
      );
      return;
    }

    // Calculate the current month as a date range
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

    // Load expense breakdown for the current month
    final expensesResult = await _treasuryRepository
        .getTransactionSummaryByType(
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

  Future<Result<void>> addTransaction(TreasuryTransaction transaction) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _treasuryRepository.addTransaction(transaction);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions(); // Reload all data after adding
    return result;
  }

  Future<Result<void>> updateTransaction(
    TreasuryTransaction transaction,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _treasuryRepository.updateTransaction(transaction);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions(); // Reload all data after updating
    return result;
  }

  Future<Result<void>> deleteTransaction(String transactionId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _treasuryRepository.deleteTransaction(transactionId);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions(); // Reload all data after deleting
    return result;
  }
}
