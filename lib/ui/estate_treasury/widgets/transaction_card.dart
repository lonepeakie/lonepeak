import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';

class TransactionCard extends ConsumerWidget {
  const TransactionCard({super.key, required this.transaction});

  final TreasuryTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountColor = transaction.isIncome ? Colors.green : Colors.red;
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final amountString =
        transaction.isIncome
            ? '+${formatter.format(transaction.amount)}'
            : '-${formatter.format(transaction.amount)}';
    final categoryColor = AppColors.getTransactionTypeColor(
      transaction.type.name,
    );
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amountString,
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              elevation: 1,
              padding: const EdgeInsets.all(0),
              onSelected: (value) => _handleMenuAction(context, value, ref),
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, WidgetRef ref) {
    if (action == 'delete') {
      _showDeleteConfirmation(context, ref);
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text(
            'Are you sure you want to delete this transaction?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            AppButton(
              onPressed: () {
                if (transaction.id != null) {
                  ref
                      .read(treasuryViewModelProvider.notifier)
                      .deleteTransaction(transaction.id!)
                      .then((result) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          if (result.isFailure && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${result.error}')),
                            );
                          }
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction deleted successfully'),
                            ),
                          );
                        }
                      });
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error: Cannot delete transaction without ID',
                      ),
                    ),
                  );
                }
              },
              buttonText: 'Delete',
              backgroundColor: Colors.red.shade400,
            ),
          ],
        );
      },
    );
  }
}
