import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<TreasuryTransaction> _transactionsRef;
  List<TreasuryTransaction> _allTransactions = [];

  TreasuryViewModel(this.estateId) : super(const TreasuryState()) {
    _transactionsRef = _firestore
        .collection('estates')
        .doc(estateId)
        .collection('transactions')
        .withConverter<TreasuryTransaction>(
          fromFirestore: (snapshot, _) =>
              TreasuryTransaction.fromJson(snapshot.data()!, id: snapshot.id),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final snapshot = await _transactionsRef.get();
      _allTransactions = snapshot.docs.map((doc) => doc.data()).toList();
      _filterAndSetState();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void applyFilters(TransactionFilters newFilters) {
    state = state.copyWith(filters: newFilters);
    _filterAndSetState();
  }

  void clearFilters() {
    applyFilters(const TransactionFilters());
  }

  Future<ViewModelResult> addTransaction(
      TreasuryTransaction transaction) async {
    try {
      final docRef = await _transactionsRef.add(transaction);
      _allTransactions.add(transaction.copyWith(id: docRef.id));
      _filterAndSetState();
      return ViewModelResult(isSuccess: true);
    } catch (e) {
      return ViewModelResult(isSuccess: false, error: e.toString());
    }
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
      filteredList
          .retainWhere((t) => !t.date.isBefore(currentFilters.startDate!));
    }
    if (currentFilters.endDate != null) {
      final inclusiveEndDate =
          currentFilters.endDate!.add(const Duration(days: 1));
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

final treasuryViewModelProvider = StateNotifierProvider.autoDispose
    .family<TreasuryViewModel, TreasuryState, String>((ref, estateId) {
  return TreasuryViewModel(estateId);
});
