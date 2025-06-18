import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';

class FilterTransactionsBottomSheet extends ConsumerStatefulWidget {
  const FilterTransactionsBottomSheet({super.key, required this.estateId});

  final String estateId;

  @override
  ConsumerState<FilterTransactionsBottomSheet> createState() =>
      _FilterTransactionsBottomSheetState();
}

class _FilterTransactionsBottomSheetState
    extends ConsumerState<FilterTransactionsBottomSheet> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  TransactionType? _selectedType;
  bool? _isIncome;

  final DateFormat _parserFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    final currentFilters =
        ref.read(treasuryViewModelProvider(widget.estateId)).filters;

    if (currentFilters.startDate != null) {
      _startDateController.text =
          _parserFormat.format(currentFilters.startDate!);
    }
    if (currentFilters.endDate != null) {
      _endDateController.text = _parserFormat.format(currentFilters.endDate!);
    }
    _selectedType = currentFilters.type;
    _isIncome = currentFilters.isIncome;
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final newFilters = TransactionFilters(
      startDate: _startDateController.text.isNotEmpty
          ? _parserFormat.parse(_startDateController.text)
          : null,
      endDate: _endDateController.text.isNotEmpty
          ? _parserFormat.parse(_endDateController.text)
          : null,
      type: _selectedType,
      isIncome: _isIncome,
    );

    ref
        .read(treasuryViewModelProvider(widget.estateId).notifier)
        .applyFilters(newFilters);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _selectedType = null;
      _isIncome = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text(
                  'Filter Transactions',
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
                Expanded(
                  child: AppDatePicker(
                    controller: _startDateController,
                    labelText: 'Start Date',
                    hintText: 'Any',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppDatePicker(
                    controller: _endDateController,
                    labelText: 'End Date',
                    hintText: 'Any',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppDropdown<TransactionType?>(
              labelText: 'Transaction Type',
              initialValue: _selectedType,
              items: [
                const DropdownItem<TransactionType?>(
                    value: null, label: 'All Types'),
                ...TransactionType.values.map(
                  (type) => DropdownItem<TransactionType?>(
                    value: type,
                    label: type.displayName,
                  ),
                ),
              ],
              onChanged: (TransactionType? newValue) {
                setState(() => _selectedType = newValue);
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Show:'),
                const SizedBox(width: 16),
                Expanded(
                  child: ToggleButtons(
                    isSelected: [
                      _isIncome == null,
                      _isIncome == false,
                      _isIncome == true,
                    ],
                    onPressed: (int index) {
                      setState(() {
                        if (index == 0) _isIncome = null;
                        if (index == 1) _isIncome = false;
                        if (index == 2) _isIncome = true;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    constraints: const BoxConstraints(minHeight: 36),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('All'),
                      ),
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                AppElevatedButton(
                  onPressed: _applyFilters,
                  buttonText: 'Apply Filters',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
