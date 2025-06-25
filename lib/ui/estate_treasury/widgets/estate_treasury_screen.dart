import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/appbar_action_button.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';
import 'package:lonepeak/ui/estate_treasury/widgets/filter_transactions_bottom_sheet.dart';
import 'package:lonepeak/ui/estate_treasury/widgets/transaction_card.dart';

class EstateTreasuryScreen extends ConsumerWidget {
  const EstateTreasuryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> estateIdAsync = ref.watch(
      currentEstateIdProvider,
    );

    return estateIdAsync.when(
      loading:
          () => Scaffold(
            appBar: AppBar(title: const Text('Treasury')),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => Scaffold(
            appBar: AppBar(title: const Text('Treasury')),
            body: Center(child: Text('Error loading estate ID: $err')),
          ),
      data: (estateId) {
        if (estateId == null || estateId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Treasury')),
            body: const Center(
              child: Text(
                'Error: No estate is currently selected.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return _EstateTreasuryView(estateId: estateId);
      },
    );
  }
}

class _EstateTreasuryView extends ConsumerWidget {
  final String estateId;
  const _EstateTreasuryView({required this.estateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treasuryState = ref.watch(treasuryViewModelProvider(estateId));
    final areFiltersActive = !treasuryState.filters.isClear;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasury'),
        actions: [
          Badge(
            isLabelVisible: areFiltersActive,
            child: IconButton(
              icon: Icon(
                areFiltersActive ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ),
          AppbarActionButton(
            icon: Icons.add,
            onPressed: () => _showAddTransactionBottomSheet(context, ref),
          ),
        ],
      ),
      body: _buildBody(context, ref, treasuryState, areFiltersActive),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    TreasuryState treasuryState,
    bool areFiltersActive,
  ) {
    if (treasuryState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (treasuryState.errorMessage != null) {
      return Center(child: Text('Error: ${treasuryState.errorMessage}'));
    }

    return RefreshIndicator(
      onRefresh:
          () =>
              ref
                  .read(treasuryViewModelProvider(estateId).notifier)
                  .loadTransactions(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentBalanceCard(context, treasuryState.currentBalance),
            const SizedBox(height: 24),
            _buildTransactionsList(
              context,
              ref,
              treasuryState.transactions,
              areFiltersActive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard(BuildContext context, double balance) {
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
              Text('Current Balance', style: AppStyles.titleTextSmall(context)),
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

  Widget _buildTransactionsList(
    BuildContext context,
    WidgetRef ref,
    List<TreasuryTransaction> transactions,
    bool areFiltersActive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              areFiltersActive ? 'Filtered Results' : 'Recent Transactions',
              style: AppStyles.titleTextSmall(context),
            ),
            if (areFiltersActive)
              TextButton(
                onPressed:
                    () =>
                        ref
                            .read(treasuryViewModelProvider(estateId).notifier)
                            .clearFilters(),
                child: const Text('Clear Filters'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        transactions.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  areFiltersActive
                      ? 'No transactions match your filters.'
                      : 'No transactions found.',
                ),
              ),
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionCard(
                  transaction: transaction,
                  estateId: estateId,
                );
              },
            ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterTransactionsBottomSheet(estateId: estateId),
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    final descriptionController = TextEditingController();
    TransactionType selectedType = TransactionType.other;
    bool isIncome = false;

    final DateFormat parserFormat = DateFormat('MMM d, yyyy');

    void submitForm() {
      if (formKey.currentState?.validate() ?? false) {
        final amount = double.tryParse(amountController.text);
        DateTime? transactionDate;
        try {
          transactionDate = parserFormat.parse(dateController.text);
        } catch (e) {
          // Handled by the null check below
        }

        if (amount == null || transactionDate == null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid amount and date.'),
            ),
          );
          return;
        }

        final newTransaction = TreasuryTransaction(
          title: titleController.text,
          amount: amount,
          type: selectedType,
          date: transactionDate,
          description:
              descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
          isIncome: isIncome,
        );

        ref
            .read(treasuryViewModelProvider(estateId).notifier)
            .addTransaction(newTransaction)
            .then((result) {
              if (!context.mounted) return;
              Navigator.of(context).pop();
              if (result.isSuccess) {
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
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
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
                          const SizedBox(width: 48),
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
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text('Transaction is: '),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ToggleButtons(
                              isSelected: [!isIncome, isIncome],
                              onPressed: (int index) {
                                setState(() => isIncome = index == 1);
                              },
                              borderRadius: BorderRadius.circular(8),
                              selectedColor: Colors.white,
                              fillColor: isIncome ? Colors.green : Colors.red,
                              constraints: const BoxConstraints(minHeight: 36),
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
                      ),
                      const SizedBox(height: 16),
                      AppTextInput(
                        controller: amountController,
                        labelText: 'Amount',
                        hintText: 'e.g. 150.00',
                        required: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          try {
                            if (double.parse(value) <= 0) {
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
                        items:
                            TransactionType.values
                                .map(
                                  (type) => DropdownItem(
                                    value: type,
                                    label: type.displayName,
                                  ),
                                )
                                .toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => selectedType = newValue);
                          }
                        },
                        required: true,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppElevatedButton(
                            onPressed: submitForm,
                            buttonText: 'Add Transaction',
                          ),
                        ],
                      ),
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
