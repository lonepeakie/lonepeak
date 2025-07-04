import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository.dart';
import 'package:lonepeak/data/repositories/estate/estate_repository_firebase.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository_firestore.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/transaction_filters.dart';
import 'package:lonepeak/utils/result.dart';

final treasuryViewModelProvider =
    StateNotifierProvider<TreasuryViewModel, TreasuryState>((ref) {
      final treasuryRepository = ref.watch(treasuryRepositoryProvider);
      final estateRepository = ref.watch(estateRepositoryProvider);
      return TreasuryViewModel(
        treasuryRepository: treasuryRepository,
        estateRepository: estateRepository,
      );
    });

class TreasuryState {
  final bool isLoading;
  final String? errorMessage;
  final List<TreasuryTransaction> transactions;
  final TransactionFilters filters;
  final double currentBalance;
  final Estate? estate;

  const TreasuryState({
    this.isLoading = true,
    this.errorMessage,
    this.transactions = const [],
    this.filters = const TransactionFilters(),
    this.currentBalance = 0.0,
    this.estate,
  });

  TreasuryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TreasuryTransaction>? transactions,
    TransactionFilters? filters,
    double? currentBalance,
    Estate? estate,
  }) {
    return TreasuryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      transactions: transactions ?? this.transactions,
      filters: filters ?? this.filters,
      currentBalance: currentBalance ?? this.currentBalance,
      estate: estate ?? this.estate,
    );
  }
}

class TreasuryViewModel extends StateNotifier<TreasuryState> {
  final TreasuryRepository _treasuryRepository;
  final EstateRepository _estateRepository;

  TreasuryViewModel({
    required TreasuryRepository treasuryRepository,
    required EstateRepository estateRepository,
  }) : _treasuryRepository = treasuryRepository,
       _estateRepository = estateRepository,
       super(TreasuryState());

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final estateResult = await _estateRepository.getEstate();
    final transactionsResult = await _treasuryRepository.getTransactions();
    final balanceResult = await _treasuryRepository.getCurrentBalance();

    if (estateResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: estateResult.error,
      );
      return;
    }

    if (transactionsResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: transactionsResult.error,
      );
      return;
    }

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
      estate: estateResult.data,
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
