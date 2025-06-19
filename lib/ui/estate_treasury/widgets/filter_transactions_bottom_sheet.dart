import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/ui/estate_treasury/view_models/treasury_viewmodel.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';

class FilterTransactionsBottomSheet extends ConsumerStatefulWidget {
  final String estateId;
  const FilterTransactionsBottomSheet({super.key, required this.estateId});

  @override
  ConsumerState<FilterTransactionsBottomSheet> createState() =>
      _FilterTransactionsBottomSheetState();
}

class _FilterTransactionsBottomSheetState
    extends ConsumerState<FilterTransactionsBottomSheet> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  TransactionType? _selectedType;
  bool? _isIncome;

  final DateFormat _parserFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    final currentFilters =
        ref.read(treasuryViewModelProvider(widget.estateId)).filters;

    if (currentFilters.startDate != null) {
      _startDateController.text = _parserFormat.format(
        currentFilters.startDate!,
      );
    }
    if (currentFilters.endDate != null) {
      _endDateController.text = _parserFormat.format(currentFilters.endDate!);
    }
    _selectedType = currentFilters.type;
    _isIncome = currentFilters.isIncome;
  }

  void _resetFilters() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _selectedType = null;
      _isIncome = null;
    });
  }

  void _applyFilters() {
    final newFilters = TransactionFilters(
      startDate:
          _startDateController.text.isNotEmpty
              ? _parserFormat.parse(_startDateController.text)
              : null,
      endDate:
          _endDateController.text.isNotEmpty
              ? _parserFormat.parse(_endDateController.text)
              : null,
      type: _selectedType,
      isIncome: _isIncome,
    );

    ref
        .read(treasuryViewModelProvider(widget.estateId).notifier)
        .setFilters(newFilters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),

          // Start Date
          TextField(
            controller: _startDateController,
            decoration: const InputDecoration(labelText: 'Start Date'),
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                _startDateController.text = _parserFormat.format(picked);
              }
            },
          ),

          const SizedBox(height: 16),

          // End Date
          TextField(
            controller: _endDateController,
            decoration: const InputDecoration(labelText: 'End Date'),
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                _endDateController.text = _parserFormat.format(picked);
              }
            },
          ),

          const SizedBox(height: 16),

          // Transaction Type Dropdown
          DropdownButtonFormField<TransactionType?>(
            decoration: const InputDecoration(labelText: 'Transaction Type'),
            value: _selectedType,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Types')),
              ...TransactionType.values.map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _selectedType = val),
          ),

          const SizedBox(height: 24),

          // Income/Expense Filter Toggle
          Row(
            children: [
              Text('Show:', style: AppStyles.subtitleText(context)),
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
              TextButton(onPressed: _resetFilters, child: const Text('Reset')),
              const SizedBox(width: 16),
              AppElevatedButton(
                onPressed: _applyFilters,
                buttonText: 'Apply Filters',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
