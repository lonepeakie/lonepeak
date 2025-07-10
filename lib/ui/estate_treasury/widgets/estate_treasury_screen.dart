import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/appbar_action_button.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';
import 'package:lonepeak/ui/estate_treasury/widgets/filter_transactions.dart';
import 'package:lonepeak/ui/estate_treasury/widgets/transaction_card.dart';

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
    Future.microtask(() {
      ref.read(treasuryViewModelProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final treasuryState = ref.watch(treasuryViewModelProvider);
    final iban = treasuryState.estate?.iban;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasury'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterBottomSheet(context),
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
      body: SafeArea(
        child:
            treasuryState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : treasuryState.errorMessage != null
                ? Center(child: Text('Error: ${treasuryState.errorMessage}'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAccountOverviewCard(
                        context,
                        treasuryState.currentBalance,
                        iban,
                      ),
                      const SizedBox(height: 24),
                      _buildRecentTransactionsContainer(
                        treasuryState.transactions,
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildAccountOverviewCard(
    BuildContext context,
    double balance,
    String? iban,
  ) {
    final formatter = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final hasIban = iban != null && iban.trim().isNotEmpty;

    return Card(
      elevation: AppStyles.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account Overview',
                  style: AppStyles.titleTextSmall(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Estate treasury account details',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 24),
            Text('IBAN', style: AppStyles.subtitleText(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasIban ? iban : 'Not Provided',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasIban)
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: iban));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('IBAN copied to clipboard'),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Current Balance', style: AppStyles.subtitleText(context)),
            const SizedBox(height: 4),
            Text(
              formatter.format(balance),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
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
          Text('Recent Transactions', style: AppStyles.titleTextSmall(context)),
          const SizedBox(height: 16),
          transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionCard(transaction: transaction);
                },
              ),
        ],
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isSubmitting = false;

            Future<void> submitForm() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              setState(() {
                isSubmitting = true;
              });

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                final newTransaction = TreasuryTransaction(
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  type: selectedType,
                  date: DateFormat('MMM d, yyyy').parse(dateController.text),
                  description:
                      descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                  isIncome: isIncome,
                );

                final result = await ref
                    .read(treasuryViewModelProvider.notifier)
                    .addTransaction(newTransaction);

                if (result.isSuccess) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Transaction added successfully'),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: ${result.error}')),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Invalid data provided')),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    isSubmitting = false;
                  });
                }
              }
            }

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
                          Text(
                            'Add Transaction',
                            style: AppStyles.titleTextSmall(context),
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
                          style: AppStyles.subtitleText(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text('Transaction is: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ToggleButtons(
                              isSelected: [!isIncome, isIncome],
                              onPressed:
                                  isSubmitting
                                      ? null
                                      : (int index) {
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
                      AppDropdown<TransactionType>(
                        labelText: 'Transaction Type',
                        initialValue: selectedType,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppElevatedButton(
                            onPressed: () {
                              if (isSubmitting) return;
                              submitForm();
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            buttonText:
                                isSubmitting ? 'Adding...' : 'Add Transaction',
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterTransactionsBottomSheet(),
    );
  }
}
