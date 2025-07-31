import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lonepeak/domain/models/metadata.dart';

enum TransactionType {
  maintenance('Maintenance'),
  insurance('Insurance'),
  utilities('Utilities'),
  rental('Rental'),
  fees('Annual Fees'),
  other('Other');

  final String displayName;

  const TransactionType(this.displayName);

  static TransactionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'maintenance':
        return TransactionType.maintenance;
      case 'insurance':
        return TransactionType.insurance;
      case 'utilities':
        return TransactionType.utilities;
      case 'rental':
        return TransactionType.rental;
      case 'fees':
        return TransactionType.fees;
      default:
        return TransactionType.other;
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

  TreasuryTransaction copyWith({
    String? id,
    String? title,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? description,
    bool? isIncome,
    Metadata? metadata,
  }) {
    return TreasuryTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      isIncome: isIncome ?? this.isIncome,
      metadata: metadata ?? this.metadata,
    );
  }
}
