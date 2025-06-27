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
