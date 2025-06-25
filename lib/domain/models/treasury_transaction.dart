import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum TransactionType { maintenance, insurance, utilities, rental, fees, other }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.maintenance:
        return 'Maintenance';
      case TransactionType.insurance:
        return 'Insurance';
      case TransactionType.utilities:
        return 'Utilities';
      case TransactionType.rental:
        return 'Rental';
      case TransactionType.fees:
        return 'Annual Fees';
      case TransactionType.other:
        return 'Other';
    }
  }
}

class TreasuryTransaction {
  final String? id;
  final String title;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? description;
  final bool isIncome;
  final Metadata? metadata;

  TreasuryTransaction({
    this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    required this.isIncome,
    this.metadata,
  });

  factory TreasuryTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TreasuryTransaction(
      id: snapshot.id,
      title: data['title'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => TransactionType.other,
      ),
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'],
      isIncome: data['isIncome'] ?? false,
      metadata: Metadata.fromJson(data['metadata']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'type': type.toString(),
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'isIncome': isIncome,
      'metadata':
          metadata?.toJson() ??
          {'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now()},
    };
  }

  TreasuryTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? description,
    bool? isIncome,
    Metadata? metadata,
  }) {
    return TreasuryTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      isIncome: isIncome ?? this.isIncome,
      metadata: metadata ?? this.metadata,
    );
  }
}

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

  bool get hasAnyFilter =>
      startDate != null || endDate != null || type != null || isIncome != null;

  bool get isClear => !hasAnyFilter;
}
