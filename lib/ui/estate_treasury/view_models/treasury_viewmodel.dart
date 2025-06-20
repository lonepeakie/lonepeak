import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/data/services/treasury/treasury_service.dart';

final treasuryServiceProvider = Provider<TreasuryService>((ref) {
  return TreasuryService();
});

final treasuryViewModelProvider = StateNotifierProvider.autoDispose
    .family<TreasuryViewModel, TreasuryState, String>((ref, estateId) {
      final treasuryService = ref.watch(treasuryServiceProvider);
      return TreasuryViewModel(estateId, treasuryService);
    });

class ViewModelResult {
  final bool isSuccess;
  final String? error;
  ViewModelResult({required this.isSuccess, this.error});
}

class TreasuryState {
  final bool isLoading;
  final String? errorMessage;
  final double currentBalance;
  final List<TreasuryTransaction> transactions;
  final TransactionFilters filters;

  const TreasuryState({
    this.isLoading = true,
    this.errorMessage,
    this.currentBalance = 0.0,
    this.transactions = const [],
    this.filters = const TransactionFilters(),
  });

  TreasuryState copyWith({
    bool? isLoading,
    String? errorMessage,
    double? currentBalance,
    List<TreasuryTransaction>? transactions,
    TransactionFilters? filters,
  }) {
    return TreasuryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentBalance: currentBalance ?? this.currentBalance,
      transactions: transactions ?? this.transactions,
      filters: filters ?? this.filters,
    );
  }
}

class TreasuryViewModel extends StateNotifier<TreasuryState> {
  final String estateId;
  final TreasuryService _treasuryService;
  List<TreasuryTransaction> _allTransactions = [];

  TreasuryViewModel(this.estateId, this._treasuryService)
    : super(const TreasuryState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _treasuryService.getTransactions(estateId);
    if (result.isSuccess) {
      _allTransactions = result.data!;
      _filterAndSetState();
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
    }
  }

  Future<ViewModelResult> addTransaction(
    TreasuryTransaction transaction,
  ) async {
    final result = await _treasuryService.addTransaction(estateId, transaction);
    if (result.isSuccess) {
      await loadTransactions();
      return ViewModelResult(isSuccess: true);
    } else {
      return ViewModelResult(isSuccess: false, error: result.error);
    }
  }

  Future<ViewModelResult> updateTransaction(
    TreasuryTransaction transaction,
  ) async {
    final result = await _treasuryService.updateTransaction(
      estateId,
      transaction,
    );
    if (result.isSuccess) {
      await loadTransactions();
      return ViewModelResult(isSuccess: true);
    } else {
      return ViewModelResult(isSuccess: false, error: result.error);
    }
  }

  Future<ViewModelResult> deleteTransaction(String transactionId) async {
    final result = await _treasuryService.deleteTransaction(
      estateId,
      transactionId,
    );
    if (result.isSuccess) {
      await loadTransactions();
      return ViewModelResult(isSuccess: true);
    } else {
      return ViewModelResult(isSuccess: false, error: result.error);
    }
  }

  Future<void> refreshBalance() async {
    final result = await _treasuryService.getCurrentBalance(estateId);
    if (result.isSuccess) {
      state = state.copyWith(currentBalance: result.data!);
    } else {
      state = state.copyWith(errorMessage: result.error);
    }
  }

  Future<Map<TransactionType, double>> getTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await _treasuryService.getTransactionSummaryByType(
      estateId,
      startDate: startDate,
      endDate: endDate,
    );
    return result.isSuccess ? result.data! : {};
  }

  void applyFilters(TransactionFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    _filterAndSetState();
  }

  void clearFilters() {
    applyFilters(const TransactionFilters());
  }

  void setFilters(TransactionFilters filters) {
    state = state.copyWith(filters: filters);
    _filterAndSetState();
  }

  void _filterAndSetState() {
    var filteredList = List<TreasuryTransaction>.from(_allTransactions);
    final currentFilters = state.filters;

    if (currentFilters.isIncome != null) {
      filteredList.retainWhere((t) => t.isIncome == currentFilters.isIncome);
    }
    if (currentFilters.type != null) {
      filteredList.retainWhere((t) => t.type == currentFilters.type);
    }
    if (currentFilters.startDate != null) {
      filteredList.retainWhere(
        (t) => !t.date.isBefore(currentFilters.startDate!),
      );
    }
    if (currentFilters.endDate != null) {
      final inclusiveEndDate = currentFilters.endDate!.add(
        const Duration(days: 1),
      );
      filteredList.retainWhere((t) => t.date.isBefore(inclusiveEndDate));
    }

    filteredList.sort((a, b) => b.date.compareTo(a.date));

    final balance = _calculateBalance(_allTransactions);

    state = state.copyWith(
      isLoading: false,
      transactions: filteredList,
      currentBalance: balance,
      errorMessage: null,
    );
  }

  double _calculateBalance(List<TreasuryTransaction> transactions) {
    return transactions.fold(0.0, (previousValue, item) {
      return item.isIncome
          ? previousValue + item.amount
          : previousValue - item.amount;
    });
  }
}
