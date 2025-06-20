import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';

Color _getCategoryColor(TransactionType type) {
  switch (type) {
    case TransactionType.maintenance:
      return Colors.blue;
    case TransactionType.insurance:
      return Colors.purple;
    case TransactionType.utilities:
      return Colors.orange;
    case TransactionType.rental:
      return Colors.green;
    case TransactionType.fees:
      return Colors.teal;
    case TransactionType.other:
      return Colors.grey;
  }
}

class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.estateId,
  });

  final TreasuryTransaction transaction;
  final String estateId;

  void _handleMenuAction(BuildContext context, String value, WidgetRef ref) {
    final viewModel = ref.read(treasuryViewModelProvider(estateId).notifier);
    if (value == 'delete') {
      viewModel.deleteTransaction(transaction.id!);
    } else if (value == 'edit') {
      // edit flow
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final amountColor = transaction.isIncome ? Colors.green : Colors.red;
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM d, yyyy');
    final amountString =
        transaction.isIncome
            ? '+${formatter.format(transaction.amount)}'
            : '-${formatter.format(transaction.amount)}';
    final categoryColor = _getCategoryColor(transaction.type);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor.withAlpha(128), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          transaction.isIncome ? Icons.south_west : Icons.north_east,
          color: amountColor,
          size: 28,
        ),
        title: Text(
          transaction.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.type.displayName,
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dateFormatter.format(transaction.date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountString,
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              elevation: 1,
              padding: const EdgeInsets.all(0),
              onSelected: (value) => _handleMenuAction(context, value, ref),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
