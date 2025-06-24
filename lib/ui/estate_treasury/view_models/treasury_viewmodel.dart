import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_provider.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

final treasuryViewModelProvider = StateNotifierProvider.autoDispose
    .family<TreasuryViewModel, TreasuryState, String>((ref, estateId) {
      final repository = ref.read(treasuryRepositoryProvider);
      return TreasuryViewModel(
        estateId: estateId,
        treasuryRepository: repository,
      );
    });

class TreasuryState {
  final bool isLoading;
  final String? errorMessage;
  final double currentBalance;
  final List<TreasuryTransaction> transactions;
  final TransactionFilters filters;
  final Map<TransactionType, double> expensesByType;

  const TreasuryState({
    this.isLoading = true,
    this.errorMessage,
    this.currentBalance = 0.0,
    this.transactions = const [],
    this.filters = const TransactionFilters(),
    this.expensesByType = const {},
  });

  TreasuryState copyWith({
    bool? isLoading,
    String? errorMessage,
    double? currentBalance,
    List<TreasuryTransaction>? transactions,
    TransactionFilters? filters,
    Map<TransactionType, double>? expensesByType,
  }) {
    return TreasuryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentBalance: currentBalance ?? this.currentBalance,
      transactions: transactions ?? this.transactions,
      filters: filters ?? this.filters,
      expensesByType: expensesByType ?? this.expensesByType,
    );
  }
}

class TreasuryViewModel extends StateNotifier<TreasuryState> {
  final String estateId;
  final TreasuryRepository treasuryRepository;

  List<TreasuryTransaction> _allTransactions = [];

  TreasuryViewModel({required this.estateId, required this.treasuryRepository})
    : super(const TreasuryState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final transactionsResult = await treasuryRepository.getTransactions();
    final balanceResult = await treasuryRepository.getCurrentBalance();

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final expensesResult = await treasuryRepository.getTransactionSummaryByType(
      startDate: firstDay,
      endDate: lastDay,
    );

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

    if (expensesResult.isFailure) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: expensesResult.error,
      );
      return;
    }

    _allTransactions = transactionsResult.data!;
    _filterAndSetState();

    state = state.copyWith(
      currentBalance: balanceResult.data!,
      expensesByType: expensesResult.data!,
    );
  }

  Future<Result<void>> addTransaction(TreasuryTransaction transaction) async {
    final newId =
        FirebaseFirestore.instance
            .collection('estates')
            .doc(estateId)
            .collection('transactions')
            .doc()
            .id;

    final transactionWithId = transaction.copyWith(id: newId);
    final result = await treasuryRepository.addTransaction(transactionWithId);

    if (result.isSuccess) {
      await loadTransactions();
    }
    return result;
  }

  Future<Result<void>> updateTransaction(
    TreasuryTransaction transaction,
  ) async {
    final result = await treasuryRepository.updateTransaction(transaction);
    if (result.isSuccess) {
      await loadTransactions();
    }
    return result;
  }

  Future<Result<void>> deleteTransaction(String transactionId) async {
    final result = await treasuryRepository.deleteTransaction(transactionId);
    if (result.isSuccess) {
      await loadTransactions();
    }
    return result;
  }

  Future<void> refreshBalance() async {
    final result = await treasuryRepository.getCurrentBalance();
    if (result.isSuccess) {
      state = state.copyWith(currentBalance: result.data!);
    } else {
      state = state.copyWith(errorMessage: result.error);
    }
  }

  void applyFilters(TransactionFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    _filterAndSetState();
  }

  void clearFilters() {
    applyFilters(const TransactionFilters());
  }

  void setFilters(TransactionFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    _filterAndSetState();
  }

  void _filterAndSetState() {
    final filters = state.filters;
    var filtered = List<TreasuryTransaction>.from(_allTransactions);

    if (filters.isIncome != null) {
      filtered.retainWhere((t) => t.isIncome == filters.isIncome);
    }
    if (filters.type != null) {
      filtered.retainWhere((t) => t.type == filters.type);
    }
    if (filters.startDate != null) {
      filtered.retainWhere((t) => !t.date.isBefore(filters.startDate!));
    }
    if (filters.endDate != null) {
      final inclusiveEnd = filters.endDate!.add(const Duration(days: 1));
      filtered.retainWhere((t) => t.date.isBefore(inclusiveEnd));
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));

    final balance = _calculateBalance(_allTransactions);

    state = state.copyWith(
      isLoading: false,
      transactions: filtered,
      currentBalance: balance,
      errorMessage: null,
    );
  }

  double _calculateBalance(List<TreasuryTransaction> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return t.isIncome ? sum + t.amount : sum - t.amount;
    });
  }
}
