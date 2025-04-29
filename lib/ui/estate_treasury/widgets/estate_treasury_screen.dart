import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';
import 'package:lonepeak/ui/estate_treasury/widgets/add_transaction_dialog.dart';

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

  // Show dialog to add a new transaction
  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransactionDialog,
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
                    // const SizedBox(height: 24),
                    // _buildExpenseBreakdownContainer(
                    //   treasuryState.expensesByType,
                    // ),
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

  Widget _buildExpenseBreakdownContainer(
    Map<TransactionType, double> expensesByType,
  ) {
    // Calculate total expenses
    final totalExpenses = expensesByType.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    // Prepare pie chart sections
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue.shade500,
      Colors.green.shade500,
      Colors.yellow.shade500,
      Colors.orange.shade500,
      Colors.purple.shade500,
      Colors.red.shade500,
    ];

    int i = 0;
    expensesByType.forEach((type, amount) {
      // Only add sections for types with values
      if (amount > 0 && totalExpenses > 0) {
        final percentage = (amount / totalExpenses * 100).round();
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: amount,
            title: '${type.displayName} $percentage%',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      i++;
    });

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expense Breakdown', style: AppStyles.titleText),
          const SizedBox(height: 16),
          Card(
            elevation: 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current month', style: AppStyles.subtitleText),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child:
                        sections.isEmpty
                            ? const Center(
                              child: Text('No expenses this month'),
                            )
                            : PieChart(
                              PieChartData(
                                sections: sections,
                                sectionsSpace: 0,
                                centerSpaceRadius: 0,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
}
