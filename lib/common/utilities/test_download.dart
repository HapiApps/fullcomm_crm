import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:xml/xml.dart';

/// Builds a Tally Prime-native XML file for direct import via:
/// Gateway of Tally → Import of Data → Vouchers
class TallyXmlExportService {
  static const String gstLedgerName = 'Input GST A/c';
  static const String gstLedgerGroup = 'Duties & Taxes';

  /// [companyName] must match the company name exactly as it appears
  /// in Tally Prime (the one active when you import).
  Future<String> exportToXml(
      List<Expense> expenses, {
        required String companyName,
        bool autoCreateLedgers = true,
        String? fileName,
      }) async {
    final builder = XmlBuilder();
    final dateFmt = DateFormat('yyyyMMdd');

    builder.processing('xml', 'version="1.0"');

    builder.element('ENVELOPE', nest: () {
      builder.element('HEADER', nest: () {
        builder.element('TALLYREQUEST', nest: 'Import Data');
      });

      builder.element('BODY', nest: () {
        builder.element('IMPORTDATA', nest: () {
          builder.element('REQUESTDESC', nest: () {
            builder.element('REPORTNAME', nest: 'Vouchers');
            builder.element('STATICVARIABLES', nest: () {
              builder.element('SVCURRENTCOMPANY', nest: companyName);
            });
          });

          builder.element('REQUESTDATA', nest: () {
            if (autoCreateLedgers) {
              _writeLedgerMasters(builder, expenses);
            }

            for (final e in expenses) {
              _writeVoucher(builder, e, dateFmt);
            }
          });
        });
      });
    });

    // Build XML once
    final xmlDoc = builder.buildDocument();
    final xmlString = xmlDoc.toXmlString(
      pretty: true,
      indent: ' ',
    );

    final name = fileName ??
        'Tally_Voucher_Import_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xml';

    // ---------------- WEB ----------------
    if (kIsWeb) {
      final blob = html.Blob([xmlString], 'application/xml');

      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..download = name
        ..style.display = 'none';

      html.document.body?.children.add(anchor);

      anchor.click();

      anchor.remove();

      html.Url.revokeObjectUrl(url);

      return name;
    }

    // ---------------- MOBILE / DESKTOP ----------------
    final dir = await getApplicationDocumentsDirectory();

    final filePath = '${dir.path}/$name';

    final file = File(filePath);

    await file.writeAsString(
      xmlString,
      flush: true,
    );

    return filePath;
  }

  /// Creates LEDGER masters for every distinct ledger used, deduped.
  /// Tally silently skips masters that already exist (reported as
  /// "duplicate" in the import log, not a fatal error), so this is
  /// safe to always include.
  void _writeLedgerMasters(XmlBuilder builder, List<Expense> expenses) {
    final Map<String, String> ledgerGroups = {}; // name -> parent group

    for (final e in expenses) {
      ledgerGroups[e.debitLedger] = e.debitGroup;
      ledgerGroups.putIfAbsent(e.creditLedger, () => _guessGroup(e.creditLedger));
      if (e.gstApplicable && e.gstAmount > 0) {
        ledgerGroups.putIfAbsent(gstLedgerName, () => gstLedgerGroup);
      }
    }

    ledgerGroups.forEach((name, group) {
      builder.element('TALLYMESSAGE', attributes: {'xmlns:UDF': 'TallyUDF'}, nest: () {
        builder.element('LEDGER', attributes: {'NAME': name, 'ACTION': 'Create'}, nest: () {
          builder.element('NAME', nest: name);
          builder.element('PARENT', nest: group);
        });
      });
    });
  }

  void _writeVoucher(XmlBuilder builder, Expense e, DateFormat dateFmt) {
    final hasGst = e.gstApplicable && e.gstAmount > 0;

    builder.element('TALLYMESSAGE', attributes: {'xmlns:UDF': 'TallyUDF'}, nest: () {
      builder.element('VOUCHER', attributes: {
        'VCHTYPE': e.voucherType,
        'ACTION': 'Create',
      }, nest: () {
        builder.element('DATE', nest: dateFmt.format(e.expenseDate));
        builder.element('NARRATION', nest: e.narration);
        builder.element('VOUCHERTYPENAME', nest: e.voucherType);
        builder.element('VOUCHERNUMBER', nest: e.voucherNo ?? '');
        builder.element('PARTYLEDGERNAME', nest: e.creditLedger);

        // Debit: expense ledger (base amount only)
        builder.element('ALLLEDGERENTRIES.LIST', nest: () {
          builder.element('LEDGERNAME', nest: e.debitLedger);
          builder.element('ISDEEMEDPOSITIVE', nest: 'Yes');
          builder.element('AMOUNT', nest: (-e.amount).toStringAsFixed(2));
        });

        // Debit: GST ledger, if applicable
        if (hasGst) {
          builder.element('ALLLEDGERENTRIES.LIST', nest: () {
            builder.element('LEDGERNAME', nest: gstLedgerName);
            builder.element('ISDEEMEDPOSITIVE', nest: 'Yes');
            builder.element('AMOUNT', nest: (-e.gstAmount).toStringAsFixed(2));
          });
        }

        // Credit: bank/cash ledger (total = base + GST)
        final totalCredit = e.amount + (hasGst ? e.gstAmount : 0);
        builder.element('ALLLEDGERENTRIES.LIST', nest: () {
          builder.element('LEDGERNAME', nest: e.creditLedger);
          builder.element('ISDEEMEDPOSITIVE', nest: 'No');
          builder.element('AMOUNT', nest: totalCredit.toStringAsFixed(2));
        });
      });
    });
  }

  String _guessGroup(String ledgerName) {
    final lower = ledgerName.toLowerCase();
    if (lower.contains('cash')) return 'Cash-in-hand';
    return 'Bank Accounts';
  }
}


class Expense {
  final DateTime expenseDate;

  /// Expense ledger
  final String debitLedger;

  /// Expense ledger group
  final String debitGroup;

  /// Bank/Cash ledger
  final String creditLedger;

  /// Base amount (without GST)
  final double amount;

  /// GST applicable
  final bool gstApplicable;

  /// GST amount
  final double gstAmount;

  /// Payment, Receipt, Journal, Contra...
  final String voucherType;

  /// Voucher Number
  final String? voucherNo;

  /// Narration
  final String narration;

  Expense({
    required this.expenseDate,
    required this.debitLedger,
    required this.debitGroup,
    required this.creditLedger,
    required this.amount,
    required this.gstApplicable,
    required this.gstAmount,
    required this.voucherType,
    this.voucherNo,
    required this.narration,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseDate: DateTime.parse(json['expense_date']),
      debitLedger: json['debit_ledger'] ?? '',
      debitGroup: json['debit_group'] ?? '',
      creditLedger: json['credit_ledger'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      gstApplicable: json['gst_applicable'] ?? false,
      gstAmount: (json['gst_amount'] ?? 0).toDouble(),
      voucherType: json['voucher_type'] ?? 'Payment',
      voucherNo: json['voucher_no'],
      narration: json['narration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_date': expenseDate.toIso8601String(),
      'debit_ledger': debitLedger,
      'debit_group': debitGroup,
      'credit_ledger': creditLedger,
      'amount': amount,
      'gst_applicable': gstApplicable,
      'gst_amount': gstAmount,
      'voucher_type': voucherType,
      'voucher_no': voucherNo,
      'narration': narration,
    };
  }
}