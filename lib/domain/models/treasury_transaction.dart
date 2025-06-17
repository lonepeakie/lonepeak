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
        return 'Rental Income';
      case TransactionType.fees:
        return 'Fees';
      case TransactionType.other:
        return 'Other';
    }
  }
}

class TreasuryTransaction {
  final String? id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? description;
  final bool isIncome;
  Metadata? metadata;

  TreasuryTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.description,
    required this.isIncome,
    this.metadata,
  });

  factory TreasuryTransaction.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    return TreasuryTransaction(
      id: id,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.other,
      ),
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'] as String?,
      isIncome: json['isIncome'] as bool,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'description': description,
      'isIncome': isIncome,
      'metadata': metadata?.toJson(),
    };
  }
}
