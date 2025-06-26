import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';
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
    _loadData();
  }

  Future<void> _loadData({bool isReload = false}) async {
    await ref
        .read(treasuryViewModelProvider.notifier)
        .loadTransactions(isReload: isReload);
  }

  void _showDownloadBottomSheet(BuildContext context) {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Date Range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDateOption(
                context,
                'Last Month',
                now.subtract(const Duration(days: 30)),
                now,
              ),
              _buildDateOption(
                context,
                'Last 3 Months',
                now.subtract(const Duration(days: 90)),
                now,
              ),
              _buildDateOption(
                context,
                'Last Year',
                now.subtract(const Duration(days: 365)),
                now,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _showCustomDatePicker(context),
                child: const Text('Custom Range'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateOption(
    BuildContext context,
    String title,
    DateTime start,
    DateTime end,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}',
      ),
      onTap: () {
        Navigator.pop(context);
        _downloadTransactions(start, end);
      },
    );
  }

  void _showCustomDatePicker(BuildContext context) {
    DateTime? startDate;
    DateTime? endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Date Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      startDate != null
                          ? DateFormat('MMM d, yyyy').format(startDate!)
                          : 'Not selected',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => startDate = date);
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(
                      endDate != null
                          ? DateFormat('MMM d, yyyy').format(endDate!)
                          : 'Not selected',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: startDate ?? DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => endDate = date);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (startDate != null && endDate != null) {
                      Navigator.pop(context);
                      _downloadTransactions(startDate!, endDate!);
                    }
                  },
                  child: const Text('Download'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadTransactions(DateTime start, DateTime end) async {
    final result = await ref
        .read(treasuryViewModelProvider.notifier)
        .downloadTransactions(startDate: start, endDate: end);

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF downloaded to Downloads folder')),
      );
      await OpenFilex.open(result.data!.path);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${result.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(treasuryViewModelProvider);
    final currencyFormat = NumberFormat.currency(symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasury'),
        actions: [
          state.isReloading
              ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: () {},
              ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showDownloadBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(isReload: true),
        child: _buildBody(state, currencyFormat),
      ),
    );
  }

  Widget _buildBody(TreasuryState state, NumberFormat currencyFormat) {
    if (state.isLoading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(state.currentBalance),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          state.currentBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (state.transactions.isEmpty)
            const Center(child: Text('No transactions found'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                return TransactionCard(transaction: state.transactions[index]);
              },
            ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    TransactionType selectedType = TransactionType.other;
    bool isIncome = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Add Transaction'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed:
                                    () => setState(() => isIncome = false),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      !isIncome ? Colors.red : null,
                                  foregroundColor:
                                      !isIncome ? Colors.white : null,
                                ),
                                child: const Text('Expense'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton(
                                onPressed:
                                    () => setState(() => isIncome = true),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      isIncome ? Colors.green : null,
                                  foregroundColor:
                                      isIncome ? Colors.white : null,
                                ),
                                child: const Text('Income'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Enter title'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixText: '€',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Enter amount';
                            if (double.tryParse(val) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(
                            DateFormat(
                              'MMM d, yyyy',
                            ).format(selectedDate ?? DateTime.now()),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TransactionType>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              TransactionType.values
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.displayName),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedType = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final txn = TreasuryTransaction(
                          title: titleController.text,
                          amount: double.parse(amountController.text),
                          type: selectedType,
                          isIncome: isIncome,
                          date: selectedDate ?? DateTime.now(),
                          description:
                              descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                        );
                        ref
                            .read(treasuryViewModelProvider.notifier)
                            .addTransaction(txn)
                            .then((_) => Navigator.pop(context));
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
        );
      },
    );
  }
}
