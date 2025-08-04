import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/providers/treasury_provider.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';

class FilterTransactionsBottomSheet extends ConsumerStatefulWidget {
  const FilterTransactionsBottomSheet({super.key});

  @override
  ConsumerState<FilterTransactionsBottomSheet> createState() =>
      _FilterTransactionsBottomSheetState();
}

class _FilterTransactionsBottomSheetState
    extends ConsumerState<FilterTransactionsBottomSheet> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool? _isIncome;
  bool _isApplying = false;

  final DateFormat _parserFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(treasuryProvider).filters;

    if (currentFilters.startDate != null) {
      _startDateController.text = _parserFormat.format(
        currentFilters.startDate!,
      );
    }
    if (currentFilters.endDate != null) {
      _endDateController.text = _parserFormat.format(currentFilters.endDate!);
    }
    _isIncome = currentFilters.isIncome;
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _isIncome = null;
    });
  }

  void _applyFilters() async {
    if (_isApplying) return;

    setState(() {
      _isApplying = true;
    });

    try {
      DateTime? startDate;
      DateTime? endDate;

      // Parse dates if provided
      if (_startDateController.text.isNotEmpty) {
        startDate = _parserFormat.parse(_startDateController.text);
      }
      if (_endDateController.text.isNotEmpty) {
        endDate = _parserFormat.parse(_endDateController.text);
      }

      // Validate date range
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start date must be before end date'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final newFilters = TransactionFilters(
        startDate: startDate,
        endDate: endDate,
        isIncome: _isIncome,
      );

      await ref.read(treasuryProvider.notifier).applyFilters(newFilters);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying filters: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),
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
          AppDatePicker(
            controller: _startDateController,
            labelText: 'Start Date',
            hintText: 'Select start date',
          ),
          const SizedBox(height: 16),
          AppDatePicker(
            controller: _endDateController,
            labelText: 'End Date',
            hintText: 'Select end date',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Show',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ToggleButtons(
                  isSelected: [
                    _isIncome == null,
                    _isIncome == false,
                    _isIncome == true,
                  ],
                  onPressed: (int index) {
                    if (_isApplying) return;
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
                onPressed: () {
                  if (!_isApplying) {
                    _resetFilters();
                  }
                },
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              AppElevatedButton(
                onPressed: () {
                  if (!_isApplying) {
                    _applyFilters();
                  }
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                buttonText: _isApplying ? 'Applying...' : 'Apply Filters',
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
