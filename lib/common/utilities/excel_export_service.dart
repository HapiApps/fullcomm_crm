// excel_export_service.dart
//
// Full function to export ALL Tally-style reports as separate TABS
// in ONE Excel workbook, and trigger download on Flutter Web.
//
// pubspec.yaml:
//   syncfusion_flutter_xlsio: ^latest
//   universal_html: ^latest
//
// Usage:
//   await ExcelExportService.exportAllReports(
//     dashboard: dashboardData,
//     dayBook: dayBookList,
//     salesRegister: salesList,
//     purchaseRegister: purchaseList,
//     ledgerEntries: ledgerList,
//     trialBalance: trialBalanceList,
//     profitLoss: plList,
//     balanceSheet: bsData,
//     receivables: receivablesList,
//     payables: payablesList,
//     stockSummary: stockList,
//     expenses: expenseList,
//   );

import 'dart:typed_data';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart' as html;

class ExcelExportService {
  /// Master function — builds one workbook with 12 tabs and downloads it.
  static Future<void> exportAllReports({
    required Map<String, dynamic> dashboard,
    required List<Map<String, dynamic>> dayBook,
    required List<Map<String, dynamic>> salesRegister,
    required List<Map<String, dynamic>> purchaseRegister,
    required List<Map<String, dynamic>> ledgerEntries,
    required List<Map<String, dynamic>> trialBalance,
    required List<Map<String, dynamic>> profitLoss,
    required Map<String, dynamic> balanceSheet,
    required List<Map<String, dynamic>> receivables,
    required List<Map<String, dynamic>> payables,
    required List<Map<String, dynamic>> stockSummary,
    required List<Map<String, dynamic>> expenses,
    String fileName = 'Tally_Reports.xlsx',
  }) async {
    final Workbook workbook = Workbook(0); // start empty, add sheets manually

    _buildDashboard(workbook, dashboard);
    _buildDayBook(workbook, dayBook);
    _buildSalesRegister(workbook, salesRegister);
    _buildPurchaseRegister(workbook, purchaseRegister);
    _buildLedger(workbook, ledgerEntries);
    _buildTrialBalance(workbook, trialBalance);
    _buildProfitLoss(workbook, profitLoss);
    _buildBalanceSheet(workbook, balanceSheet);
    _buildReceivables(workbook, receivables);
    _buildPayables(workbook, payables);
    _buildStockSummary(workbook, stockSummary);
    _buildExpenseReport(workbook, expenses);

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    _downloadFile(Uint8List.fromList(bytes), fileName);
  }

  // ---------------- SHEET BUILDERS ----------------

  static Worksheet _newSheet(Workbook wb, String name) {
    final Worksheet sheet = wb.worksheets.addWithName(name);
    return sheet;
  }

  static void _writeHeader(Worksheet sheet, List<String> headers, {int row = 1}) {
    for (int i = 0; i < headers.length; i++) {
      final Range cell = sheet.getRangeByIndex(row, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#D9E1F2';
    }
  }

  static void _autoFit(Worksheet sheet, int columnCount) {
    for (int i = 1; i <= columnCount; i++) {
      sheet.autoFitColumn(i);
    }
  }

  static void _buildDashboard(Workbook wb, Map<String, dynamic> data) {
    final sheet = _newSheet(wb, 'Dashboard');
    _writeHeader(sheet, ['Details', 'Value']);
    final entries = <String, String>{
      'Total Sales': data['totalSales']?.toString() ?? '',
      'Total Purchase': data['totalPurchase']?.toString() ?? '',
      'Total Expenses': data['totalExpenses']?.toString() ?? '',
      'Total Receipts': data['totalReceipts']?.toString() ?? '',
      'Total Payments': data['totalPayments']?.toString() ?? '',
      'Cash Balance': data['cashBalance']?.toString() ?? '',
      'Bank Balance': data['bankBalance']?.toString() ?? '',
      'Profit': data['profit']?.toString() ?? '',
    };
    int row = 2;
    entries.forEach((k, v) {
      sheet.getRangeByIndex(row, 1).setText(k);
      sheet.getRangeByIndex(row, 2).setText(v);
      row++;
    });
    _autoFit(sheet, 2);
  }

  static void _buildDayBook(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Day Book');
    final headers = ['Date', 'Voucher No', 'Type', 'Particulars', 'Debit', 'Credit'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['date']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setText(row['voucherNo']?.toString() ?? '');
      sheet.getRangeByIndex(r, 3).setText(row['type']?.toString() ?? '');
      sheet.getRangeByIndex(r, 4).setText(row['particulars']?.toString() ?? '');
      sheet.getRangeByIndex(r, 5).setNumber((row['debit'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 6).setNumber((row['credit'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildSalesRegister(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Sales Register');
    final headers = ['Date', 'Invoice No', 'Customer', 'Amount', 'GST', 'Total'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['date']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setText(row['invoiceNo']?.toString() ?? '');
      sheet.getRangeByIndex(r, 3).setText(row['customer']?.toString() ?? '');
      sheet.getRangeByIndex(r, 4).setNumber((row['amount'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 5).setNumber((row['gst'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 6).setNumber((row['total'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildPurchaseRegister(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Purchase Register');
    final headers = ['Date', 'Bill No', 'Supplier', 'Amount', 'GST', 'Total'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['date']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setText(row['billNo']?.toString() ?? '');
      sheet.getRangeByIndex(r, 3).setText(row['supplier']?.toString() ?? '');
      sheet.getRangeByIndex(r, 4).setNumber((row['amount'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 5).setNumber((row['gst'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 6).setNumber((row['total'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildLedger(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Ledger');
    final headers = ['Date', 'Voucher', 'Particulars', 'Debit', 'Credit', 'Balance'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['date']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setText(row['voucher']?.toString() ?? '');
      sheet.getRangeByIndex(r, 3).setText(row['particulars']?.toString() ?? '');
      sheet.getRangeByIndex(r, 4).setNumber((row['debit'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 5).setNumber((row['credit'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 6).setText(row['balance']?.toString() ?? '');
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildTrialBalance(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Trial Balance');
    final headers = ['Ledger', 'Debit', 'Credit'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['ledger']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setNumber((row['debit'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 3).setNumber((row['credit'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildProfitLoss(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Profit and Loss');
    final headers = ['Particulars', 'Amount'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['particulars']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setNumber((row['amount'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildBalanceSheet(Workbook wb, Map<String, dynamic> data) {
    final sheet = _newSheet(wb, 'Balance Sheet');
    // Assets block
    sheet.getRangeByIndex(1, 1).setText('Assets');
    sheet.getRangeByIndex(1, 1).cellStyle.bold = true;
    _writeHeader(sheet, ['Particulars', 'Amount'], row: 2);
    int r = 3;
    final assets = (data['assets'] as List<Map<String, dynamic>>? ?? []);
    for (final row in assets) {
      sheet.getRangeByIndex(r, 1).setText(row['particulars']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setNumber((row['amount'] ?? 0).toDouble());
      r++;
    }
    r += 1;
    // Liabilities block
    sheet.getRangeByIndex(r, 1).setText('Liabilities');
    sheet.getRangeByIndex(r, 1).cellStyle.bold = true;
    r++;
    _writeHeader(sheet, ['Particulars', 'Amount'], row: r);
    r++;
    final liabilities = (data['liabilities'] as List<Map<String, dynamic>>? ?? []);
    for (final row in liabilities) {
      sheet.getRangeByIndex(r, 1).setText(row['particulars']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setNumber((row['amount'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, 2);
  }

  static void _buildReceivables(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Outstanding Receivables');
    final headers = ['Customer', 'Amount', 'Due Days'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['customer']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setNumber((row['amount'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 3).setNumber((row['dueDays'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildPayables(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Outstanding Payables');
    final headers = ['Supplier', 'Amount', 'Due Days'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['supplier']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setNumber((row['amount'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 3).setNumber((row['dueDays'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildStockSummary(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Stock Summary');
    final headers = ['Product', 'Opening', 'Inward', 'Outward', 'Closing'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['product']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setNumber((row['opening'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 3).setNumber((row['inward'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 4).setNumber((row['outward'] ?? 0).toDouble());
      sheet.getRangeByIndex(r, 5).setNumber((row['closing'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  static void _buildExpenseReport(Workbook wb, List<Map<String, dynamic>> rows) {
    final sheet = _newSheet(wb, 'Expense Report');
    final headers = ['Date', 'Expense Head', 'Amount'];
    _writeHeader(sheet, headers);
    int r = 2;
    for (final row in rows) {
      sheet.getRangeByIndex(r, 1).setText(row['date']?.toString() ?? '');
      sheet.getRangeByIndex(r, 2).setText(row['expenseHead']?.toString() ?? '');
      sheet.getRangeByIndex(r, 3).setNumber((row['amount'] ?? 0).toDouble());
      r++;
    }
    _autoFit(sheet, headers.length);
  }

  // ---------------- WEB DOWNLOAD ----------------

  static void _downloadFile(Uint8List bytes, String fileName) {
    final blob = html.Blob(
      [bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}