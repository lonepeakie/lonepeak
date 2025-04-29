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

  String get iconData {
    switch (this) {
      case TransactionType.maintenance:
        return 'construction';
      case TransactionType.insurance:
        return 'shield';
      case TransactionType.utilities:
        return 'power';
      case TransactionType.rental:
        return 'home';
      case TransactionType.fees:
        return 'payments';
      case TransactionType.other:
        return 'more_horiz';
    }
  }
}

class TreasuryTransaction {
  String? id;
  String title;
  TransactionType type;
  double amount;
  DateTime date;
  String? description;
  bool isIncome;
  Metadata? metadata;

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
}
