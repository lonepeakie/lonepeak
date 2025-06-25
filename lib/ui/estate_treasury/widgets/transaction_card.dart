import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.estateId,
  });

  final TreasuryTransaction transaction;
  final String estateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountColor = transaction.isIncome ? Colors.green : Colors.red;
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final amountString =
        transaction.isIncome
            ? '+${formatter.format(transaction.amount)}'
            : '-${formatter.format(transaction.amount)}';
    final categoryColor = _getCategoryColor(transaction.type);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          transaction.isIncome ? Icons.south_west : Icons.arrow_outward,
          color: transaction.isIncome ? Colors.green : Colors.red,
        ),
        title: Text(
          transaction.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Column(
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.type.displayName,
                    style: TextStyle(color: categoryColor, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  dateFormatter.format(transaction.date),
                  style: TextStyle(
                    color:
                        theme.brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          amountString,
          style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

Color _getCategoryColor(TransactionType type) {
  switch (type) {
    case TransactionType.maintenance:
      return Colors.blue;
    case TransactionType.insurance:
      return Colors.purple;
    case TransactionType.utilities:
      return Colors.yellow.shade800;
    case TransactionType.rental:
      return Colors.green;
    case TransactionType.fees:
      return Colors.teal;
    case TransactionType.other:
      return Colors.deepPurpleAccent;
  }
}
