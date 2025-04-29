import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/appbar_action_button.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';

class EstateTreasuryScreen extends ConsumerStatefulWidget {
  const EstateTreasuryScreen({super.key});

  @override
  ConsumerState<EstateTreasuryScreen> createState() =>
      _EstateTreasuryScreenState();
}

class _EstateTreasuryScreenState extends ConsumerState<EstateTreasuryScreen> {
  @override
  void initState() {
    super.initState();
    // Load transactions when screen initializes
    Future.microtask(
      () => ref.read(treasuryViewModelProvider.notifier).loadTransactions(),
    );
  }

  // Show bottom sheet to add a new transaction
  @override
  Widget build(BuildContext context) {
    final treasuryState = ref.watch(treasuryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasury'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
          AppbarActionButton(
            icon: Icons.add,
            onPressed: () => _showAddTransactionBottomSheet(context),
          ),
        ],
      ),
      body:
          treasuryState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : treasuryState.errorMessage != null
              ? Center(child: Text('Error: ${treasuryState.errorMessage}'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentBalanceCard(treasuryState.currentBalance),
                    const SizedBox(height: 24),
                    _buildRecentTransactionsContainer(
                      treasuryState.transactions,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildCurrentBalanceCard(double balance) {
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0.3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Balance', style: AppStyles.titleText),
              const SizedBox(height: 8),
              Text(
                formatter.format(balance),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsContainer(
    List<TreasuryTransaction> transactions,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Transactions', style: AppStyles.titleText),
          const SizedBox(height: 16),
          transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final formatter = NumberFormat.currency(
                    symbol: '€',
                    decimalDigits: 2,
                  );
                  final amount =
                      transaction.isIncome
                          ? '+${formatter.format(transaction.amount)}'
                          : '-${formatter.format(transaction.amount)}';
                  final color =
                      transaction.isIncome ? Colors.green : Colors.red;
                  final dateFormatter = DateFormat('yyyy-MM-dd');

                  return _buildTransactionCard(
                    title: transaction.title,
                    category: transaction.type.displayName,
                    categoryColor: _getCategoryColor(transaction.type),
                    date: dateFormatter.format(transaction.date),
                    amount: amount,
                    amountColor: color,
                    isIncome: transaction.isIncome,
                  );
                },
              ),
        ],
      ),
    );
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

  Widget _buildTransactionCard({
    required String title,
    required String category,
    required Color categoryColor,
    required String date,
    required String amount,
    required Color amountColor,
    required bool isIncome,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.south_west : Icons.arrow_outward,
          color: isIncome ? Colors.green : Colors.red,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    category,
                    style: TextStyle(color: categoryColor, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          amount,
          style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    final descriptionController = TextEditingController();
    TransactionType selectedType = TransactionType.other;
    bool isIncome = false;

    void submitForm() {
      if (formKey.currentState!.validate()) {
        final newTransaction = TreasuryTransaction(
          title: titleController.text,
          amount: double.parse(amountController.text),
          type: selectedType,
          date: DateTime.parse(dateController.text),
          description:
              descriptionController.text.isEmpty
                  ? null
                  : descriptionController.text,
          isIncome: isIncome,
        );

        ref
            .read(treasuryViewModelProvider.notifier)
            .addTransaction(newTransaction)
            .then((result) {
              if (result.isSuccess) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction added successfully'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${result.error}')),
                );
              }
            });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 24),
                          const Text(
                            'Add Transaction',
                            style: AppStyles.titleText,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Add a new financial transaction to the estate treasury.',
                          style: AppStyles.subtitleText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Income/Expense toggle
                      Row(
                        children: [
                          const Text('Transaction is: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ToggleButtons(
                              isSelected: [!isIncome, isIncome],
                              onPressed: (int index) {
                                setState(() {
                                  isIncome = index == 1;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              selectedColor: Colors.white,
                              fillColor: isIncome ? Colors.green : Colors.red,
                              constraints: const BoxConstraints(minHeight: 32),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('Expense'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('Income'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextInput(
                        controller: titleController,
                        labelText: 'Title',
                        hintText: 'e.g. Community garden Repair',
                        required: true,
                        errorText: 'Title is required',
                      ),
                      const SizedBox(height: 16),
                      AppTextInput(
                        controller: amountController,
                        labelText: 'Amount',
                        hintText: 'e.g. 150.00',
                        required: true,
                        errorText: 'Amount is required',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          try {
                            final amount = double.parse(value);
                            if (amount <= 0) {
                              return 'Amount must be greater than 0';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppDatePicker(
                        controller: dateController,
                        labelText: 'Transaction Date',
                        hintText: 'Select a date',
                        required: true,
                        errorText: 'Please select a date',
                      ),
                      const SizedBox(height: 16),
                      AppTextInput(
                        controller: descriptionController,
                        labelText: 'Description (optional)',
                        hintText: 'Additional details about the transaction',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Use the generic AppDropdown component
                      AppDropdown<TransactionType>(
                        labelText: 'Transaction Type',
                        value: selectedType,
                        required: true,
                        errorText: 'Please select a transaction type',
                        items:
                            TransactionType.values
                                .map(
                                  (type) => DropdownItem<TransactionType>(
                                    value: type,
                                    label: type.displayName,
                                  ),
                                )
                                .toList(),
                        onChanged: (TransactionType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedType = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppElevatedButton(
                            onPressed: submitForm,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            buttonText: 'Add',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
