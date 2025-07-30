import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository_firestore.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/transaction_filters.dart';
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
  final TransactionFilters filters;
  final double currentBalance;

  const TreasuryState({
    this.isLoading = true,
    this.errorMessage,
    this.transactions = const [],
    this.filters = const TransactionFilters(),
    this.currentBalance = 0.0,
  });

  TreasuryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TreasuryTransaction>? transactions,
    TransactionFilters? filters,
    double? currentBalance,
  }) {
    return TreasuryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      transactions: transactions ?? this.transactions,
      filters: filters ?? this.filters,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }
}

class TreasuryViewModel extends StateNotifier<TreasuryState> {
  final TreasuryRepository _treasuryRepository;

  TreasuryViewModel({required TreasuryRepository treasuryRepository})
    : _treasuryRepository = treasuryRepository,
      super(const TreasuryState());

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final transactionsResult = await _treasuryRepository.getTransactions();
    if (transactionsResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: transactionsResult.error,
      );
      return;
    }

    final balanceResult = await _treasuryRepository.getCurrentBalance();
    if (balanceResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: balanceResult.error,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      transactions: transactionsResult.data,
      currentBalance: balanceResult.data,
    );
  }

  Future<Result<void>> addTransaction(TreasuryTransaction transaction) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _treasuryRepository.addTransaction(transaction);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions();
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

    await loadTransactions();
    return result;
  }

  Future<Result<void>> deleteTransaction(String transactionId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _treasuryRepository.deleteTransaction(transactionId);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions();
    return result;
  }

  void applyFilters(TransactionFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    filterTransactions();
  }

  void clearFilters() {
    applyFilters(const TransactionFilters());
  }

  void setFilters(TransactionFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    filterTransactions();
  }

  Future<void> filterTransactions() async {
    final currentFilters = state.filters;
    final result = await _treasuryRepository.getTransactionsBetweenDates(
      startDate: currentFilters.startDate,
      endDate: currentFilters.endDate,
    );

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return;
    }

    final trxs = result.data!;
    if (currentFilters.isIncome != null) {
      trxs.retainWhere((trx) => trx.isIncome == currentFilters.isIncome);
    }

    state = state.copyWith(
      isLoading: false,
      transactions: trxs,
      filters: currentFilters,
    );
  }
}
