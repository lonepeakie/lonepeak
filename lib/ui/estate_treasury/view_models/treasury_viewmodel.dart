import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_provider.dart';
import 'package:lonepeak/data/repositories/treasury/treasury_repository.dart';
import 'package:lonepeak/domain/models/treasury_transaction.dart';
import 'package:lonepeak/utils/result.dart';

final treasuryViewModelProvider =
    StateNotifierProvider<TreasuryViewModel, TreasuryState>((ref) {
      final treasuryRepository = ref.watch(treasuryRepositoryProvider);
      return TreasuryViewModel(treasuryRepository: treasuryRepository);
    });

class TreasuryState {
  final bool isLoading;
  final bool isReloading;
  final String? errorMessage;
  final List<TreasuryTransaction> transactions;
  final double currentBalance;
  final Map<TransactionType, double> expensesByType;

  TreasuryState({
    this.isLoading = false,
    this.isReloading = false,
    this.errorMessage,
    this.transactions = const [],
    this.currentBalance = 0.0,
    this.expensesByType = const {},
  });

  TreasuryState copyWith({
    bool? isLoading,
    bool? isReloading,
    String? errorMessage,
    List<TreasuryTransaction>? transactions,
    double? currentBalance,
    Map<TransactionType, double>? expensesByType,
  }) {
    return TreasuryState(
      isLoading: isLoading ?? this.isLoading,
      isReloading: isReloading ?? this.isReloading,
      errorMessage: errorMessage ?? this.errorMessage,
      transactions: transactions ?? this.transactions,
      currentBalance: currentBalance ?? this.currentBalance,
      expensesByType: expensesByType ?? this.expensesByType,
    );
  }
}

class TreasuryViewModel extends StateNotifier<TreasuryState> {
  TreasuryViewModel({required TreasuryRepository treasuryRepository})
    : _treasuryRepository = treasuryRepository,
      super(TreasuryState()) {
    loadTransactions();
  }

  final TreasuryRepository _treasuryRepository;

  get context => null;

  Future<void> loadTransactions({bool isReload = false}) async {
    if (state.isLoading || state.isReloading) return;

    state = state.copyWith(
      isLoading: !isReload,
      isReloading: isReload,
      errorMessage: null,
    );

    try {
      final transactionsResult = await _treasuryRepository.getTransactions();
      if (transactionsResult.isFailure) {
        state = state.copyWith(
          isLoading: false,
          isReloading: false,
          errorMessage: transactionsResult.error,
          transactions: [],
        );
        return;
      }

      final balanceResult = await _treasuryRepository.getCurrentBalance();
      if (balanceResult.isFailure) {
        state = state.copyWith(
          isLoading: false,
          isReloading: false,
          errorMessage: balanceResult.error,
          transactions: transactionsResult.data,
        );
        return;
      }

      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final expensesResult = await _treasuryRepository
          .getTransactionSummaryByType(
            startDate: firstDayOfMonth,
            endDate: lastDayOfMonth,
          );

      state = state.copyWith(
        isLoading: false,
        isReloading: false,
        transactions: transactionsResult.data,
        currentBalance: balanceResult.data,
        expensesByType: expensesResult.data ?? {},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isReloading: false,
        errorMessage: 'Failed to load transactions: $e',
        transactions: [],
      );
    }
  }

  Future<void> reloadTransactions() async {
    if (state.isReloading) return;
    await loadTransactions(isReload: true);
  }

  Future<Result<void>> addTransaction(TreasuryTransaction transaction) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _treasuryRepository.addTransaction(transaction);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions();
    return result;
  }

  Future<Result<void>> updateTransaction(
    TreasuryTransaction transaction,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _treasuryRepository.updateTransaction(transaction);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions();
    return result;
  }

  Future<Result<void>> deleteTransaction(String transactionId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _treasuryRepository.deleteTransaction(transactionId);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.error);
      return result;
    }

    await loadTransactions();
    return result;
  }

  Future<Result<File>> downloadTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load OpenSans font from assets
      final fontData = await rootBundle.load(
        'assets/fonts/OpenSans-Regular.ttf',
      );
      final openSansFont = pw.Font.ttf(fontData);

      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          return Result.failure('Storage permission denied');
        }
      }

      final filteredTransactions =
          state.transactions.where((t) {
            return t.date.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                t.date.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();

      if (filteredTransactions.isEmpty) {
        return Result.failure('No transactions found in selected date range');
      }

      final pdf = pw.Document(theme: pw.ThemeData.withFont(base: openSansFont));
      final dateFormat = DateFormat('yyyy-MM-dd');
      final currencyFormat = NumberFormat.currency(
        symbol: '€',
        decimalDigits: 2,
        customPattern: '€#,##0.00;€-#,##0.00',
      );

      // First page with header and summary
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header section
                pw.Center(
                  child: pw.Text(
                    'Lone Peak Treasury Report',
                    style: pw.TextStyle(
                      font: openSansFont,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    '${dateFormat.format(startDate)} to ${dateFormat.format(endDate)}',
                    style: pw.TextStyle(font: openSansFont, fontSize: 14),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Current Balance: ${currencyFormat.format(state.currentBalance)}',
                  style: pw.TextStyle(
                    font: openSansFont,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Generated on: ${dateFormat.format(DateTime.now())}',
                  style: pw.TextStyle(font: openSansFont, fontSize: 12),
                ),
                pw.Divider(height: 20, thickness: 1),
                pw.Text(
                  'Transaction Summary',
                  style: pw.TextStyle(
                    font: openSansFont,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildSummaryTable(
                  filteredTransactions,
                  currencyFormat,
                  openSansFont,
                ),
              ],
            );
          },
        ),
      );

      // Transaction details table with automatic pagination
      final detailsTable = pw.TableHelper.fromTextArray(
        context: context,
        headers: ['Date', 'Title', 'Type', 'Amount', 'Description'],
        data:
            filteredTransactions
                .map(
                  (t) => [
                    dateFormat.format(t.date),
                    t.title,
                    t.type.displayName,
                    t.isIncome
                        ? '+${currencyFormat.format(t.amount)}'
                        : '-${currencyFormat.format(t.amount)}',
                    t.description ?? '-',
                  ],
                )
                .toList(),
        headerStyle: pw.TextStyle(
          font: openSansFont,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        cellStyle: pw.TextStyle(font: openSansFont, fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerLeft,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerLeft,
        },
        columnWidths: {
          0: const pw.FixedColumnWidth(60),
          1: const pw.FlexColumnWidth(1.5),
          2: const pw.FixedColumnWidth(50),
          3: const pw.FixedColumnWidth(60),
          4: const pw.FlexColumnWidth(2),
        },
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginLeft: 30, // Left margin in points (1/72 inch)
            marginRight: 30, // Right margin in points
            marginTop: 40, // Top margin
            marginBottom: 40, // Bottom margin
          ),
          build:
              (pw.Context context) => [
                pw.Text(
                  'Transaction Details',
                  style: pw.TextStyle(
                    font: openSansFont,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                detailsTable,
              ],
        ),
      );

      // Save PDF to device
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null || !await downloadsDir.exists()) {
        return Result.failure('Could not access downloads directory');
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Treasury_Report_$timestamp.pdf';
      final file = File('${downloadsDir.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      state = state.copyWith(isLoading: false);
      return Result.success(file);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate PDF: $e',
      );
      return Result.failure('Failed to generate PDF: $e');
    }
  }

  pw.Widget _buildSummaryTable(
    List<TreasuryTransaction> transactions,
    NumberFormat currencyFormat,
    pw.Font openSansFont,
  ) {
    final summaryData = _getSummaryData(transactions, currencyFormat);

    return pw.Table.fromTextArray(
      headers: ['Type', 'Income', 'Expense'],
      data: summaryData,
      headerStyle: pw.TextStyle(
        font: openSansFont,
        fontWeight: pw.FontWeight.bold,
        fontSize: 12,
      ),
      cellStyle: pw.TextStyle(font: openSansFont, fontSize: 12),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  List<List<String>> _getSummaryData(
    List<TreasuryTransaction> transactions,
    NumberFormat currencyFormat,
  ) {
    final incomeByType = <TransactionType, double>{};
    final expenseByType = <TransactionType, double>{};

    for (var t in transactions) {
      if (t.isIncome) {
        incomeByType.update(
          t.type,
          (value) => value + t.amount,
          ifAbsent: () => t.amount,
        );
      } else {
        expenseByType.update(
          t.type,
          (value) => value + t.amount,
          ifAbsent: () => t.amount,
        );
      }
    }

    final allTypes =
        {...incomeByType.keys, ...expenseByType.keys}.toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return allTypes.map((type) {
      return [
        type.displayName,
        incomeByType.containsKey(type)
            ? currencyFormat.format(incomeByType[type]!)
            : '-',
        expenseByType.containsKey(type)
            ? currencyFormat.format(expenseByType[type]!)
            : '-',
      ];
    }).toList();
  }
}
