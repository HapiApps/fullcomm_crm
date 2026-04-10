import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/view_models/billing_provider.dart';
import '../../common/billing_data/project_data.dart';
import '../../models/billing_models/order_details.dart';
import '../../view_models/customer_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'direct_print.dart';

class BillPdf {

  // Pdf Widgets :
  pw.TextStyle billText = const pw.TextStyle(
    color: PdfColors.black,
    fontSize: 11,
  );
  pw.TextStyle billSaveText =  pw.TextStyle(
    color: PdfColors.black,
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
  );

  pw.TextStyle billTextBold = pw.TextStyle(
      color: PdfColors.black,
      fontSize: 13,
      fontWeight: pw.FontWeight.bold
  );

  pw.TextStyle simpleText = const pw.TextStyle(
    color: PdfColors.black,
    fontSize: 10,
  );

  int detectCharPerLine(String printerName) {
    final name = printerName.toLowerCase();

    if (name.contains("rp3160") ||
        name.contains("rp-3160") ||
        name.contains("star") ||
        name.contains("58")||name.contains("epson")) {
      return 42;  // RP3160 58mm print head
    }

    return 48;    // Retsol 80mm print head
  }

// Choose ESC/POS paper size dynamically
  PaperSize detectPaperSize(String printerName) {
    int chars = detectCharPerLine(printerName);
    return chars == 42 ? PaperSize.mm58 : PaperSize.mm80;
  }

  Future<bool> printBill(BuildContext context, {required int invoiceNo}) async {
    try {
      if (!context.mounted) return false;

      final billingProvider =
      Provider.of<BillingProvider>(context, listen: false);
      final customerProvider =
      Provider.of<CustomersProvider>(context, listen: false);

      // ------------------ CALCULATIONS ------------------
      final displayOTotal = billingProvider.calculatedGrandTotal().toString();
      final displayReceived =
      billingProvider.paymentReceived.text == "0" ||
          billingProvider.paymentReceived.text == "0.0"
          ? displayOTotal
          : billingProvider.paymentReceived.text;

      double total = double.tryParse(displayOTotal) ?? 0;
      double receivedAmt = double.tryParse(displayReceived) ?? total;

      double upiPaid = billingProvider.selectBillMethod == "Split Payment"
          ? double.tryParse(billingProvider.upiPayment.text) ?? 0
          : 0;

      double payback = (receivedAmt + upiPaid) - total;
      if (payback < 0) payback = 0;

      // ------------------ ESC/POS SETUP (MM58) ------------------
      final profile = await CapabilityProfile.load();
      final printers = WindowsRawPrinter.listPrinters();
      if (printers.isEmpty) {
        print("❌ No printers found");
        return false;
      }
      final defaultPrinter = getDefaultPrinter();
      final generator = Generator(detectPaperSize(defaultPrinter), profile);
      List<int> bytes = []; // growable list

      // ------------------ LOGO (Optional) ------------------
      try {
        final logoBytes =
        (await rootBundle.load('assets/images/mart1.png')).buffer.asUint8List();

        final decoded = img.decodeImage(logoBytes);

        if (decoded != null) {
          final resized = img.copyResize(
            decoded,
            width: 280, // mm58, so little smaller
            height: 80,
          );

          bytes += generator.imageRaster(
            resized,
            align: PosAlign.center,

          );
          // bytes += generator.emptyLines(1);
        }
      } catch (e) {
        print("❌ Logo print failed: $e");
      }

      // ------------------ BUSINESS DETAILS ------------------


      bytes += generator.text(
        ProjectData.billAddress.replaceAll("\n", " "),
        styles: PosStyles(align: PosAlign.center,fontType: PosFontType.fontB),
      );


      bytes += generator.text(
        ProjectData.billMobile,
        styles: PosStyles(align: PosAlign.center,fontType: PosFontType.fontB),
      );



      // ------------------ BILL DETAILS ------------------
      final now = DateTime.now();

      // Bill No + Date
      int chars = detectCharPerLine(defaultPrinter);
      bytes += generator.row([
        PosColumn(
          text: "Bill No : $invoiceNo",
          width: chars == 42? 5 : 6,
          styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: "Dt: ${DateFormat('dd-MM-yyyy').format(now)}/${DateFormat('h:mm a').format(now)}",
          width: chars == 42? 7 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);


// ------------------ CUSTOMER DETAILS ------------------
      if (customerProvider.selectedCustomerName.isNotEmpty) {
        bytes += generator.row([
          PosColumn(
            text: "Mobile  : ${customerProvider.selectedCustomerMobile.trim()}",
            width: 6,
            styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: "Name : ${customerProvider.selectedCustomerName.trim()}",
            width: 6,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
        ]);
      }

      if (customerProvider.customerAddressController.text.trim().isNotEmpty) {
        bytes += generator.row([
          PosColumn(
            text:   "Address : ${customerProvider.customerAddressController.text.trim()}",
            width: 6,
            styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: "",
            width: 6,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
        ]);
      }

      bytes += generator.hr();

      // ------------------ TABLE HEADER (WITH MRP) ------------------
      bytes += generator.row([
        PosColumn(
            text: "Product",
            width: chars == 42? 3 : 4,
            styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB)),
        PosColumn(
            text: "Qty",
            width: chars == 42? 3 : 2,
            styles: PosStyles(bold: true, align: PosAlign.center,fontType: PosFontType.fontB)),
    PosColumn(
            text: "MRP",
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB)),
        PosColumn(
            text: "Rate",
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB)),
        PosColumn(
            text: "Total",
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB)),
      ]);

      // bytes += generator.text(
      //   '------------------------------',
      //   styles: const PosStyles(align: PosAlign.center),
      // );
      bytes += generator.hr();

      // ------------------ ITEMS LIST (WITH MRP) ------------------
    for (var item in billingProvider.billingItems) { // normal
    //  for (var item in billingProvider.billingItems.reversed) { //reverse
        String qty;

        if (item.product.isLoose == "1") {
          qty = ((double.tryParse(item.variation.toString()) ?? 0) / 1000)
              .toStringAsFixed(3);
        } else {
          qty = item.quantity.toString();
        }

        final mrp = item.mrpPerProduct().toStringAsFixed(2);
        final rate = item.outPricePerProduct().toStringAsFixed(2);
        final totalLine = item.calculateBillSubtotal().toStringAsFixed(2);

        bytes += generator.row([
          PosColumn(
            text: (item.product.isLoose == "1") ? "${item.productTitle}-L".trim() : "${item.productTitle} ${item.variationUnit}".trim(),
            width: chars == 42? 3 : 4,
            styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: qty,
            width: chars == 42 ? 3 : 2,
       styles:(item.product.isLoose == "1")? PosStyles(align: PosAlign.right,fontType: PosFontType.fontB): PosStyles(align: PosAlign.center,fontType: PosFontType.fontB),),

          PosColumn(
            text: mrp,
            width: 2,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: rate,
            width: 2,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: totalLine,
            width: 2,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
        ]);
      }

      bytes += generator.hr();

      // ------------------ TOTALS ------------------
      bytes += generator.row([
        PosColumn(
          text:
          "Items: ${billingProvider.calculatedTotalProducts()}",
          width: chars == 42? 3 : 2,
          styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text:
          "Qty: ${billingProvider.calculatedTotalQuantity()}",
          width: chars == 42? 7 : 3,
          styles: PosStyles(bold: true, align: chars == 42? PosAlign.left : PosAlign.right,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text:"",
          width:chars == 42? 2 : 7,
          styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text:"",
          width:2,
          styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: "Grand Total:",
          width: 5,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
          ),
        ),
        PosColumn(
          text: billingProvider
              .calculatedGrandTotal()
              .toStringAsFixed(2),
          width: 5,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size2,
          ),
        ),
      ]);

      // ------------------ PAYMENT ------------------
      bytes += generator.row([
        PosColumn(text: "Received:", width: chars == 42? 5 : 3),
        PosColumn(
          text: receivedAmt.toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),PosColumn(
          text: "",
          width: chars == 42? 4 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: "Payback:", width: chars == 42? 5 : 3),
        PosColumn(
          text: payback.toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),PosColumn(
          text: "",
          width: chars == 42? 4 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: "Total Gst: 18 %",
          width: chars == 42? 5 : 3,
          styles: PosStyles(bold: true,fontType: PosFontType.fontB,),
        ),
        PosColumn(
          text: "0.00", // unga GST value vechukonga
          width: 3,
          styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB,),
        ),PosColumn(
          text: "",
          width: chars == 42? 4 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);

      // ------------------ SAVINGS ------------------
      bytes += generator.hr();
      bytes += generator.text(
        "Your Savings: ${billingProvider.calculateTotalDiscount()}",
        styles: PosStyles(
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          align: PosAlign.center,
        ),
      );
      bytes += generator.hr();

      // ------------------ FOOTER ------------------
      bytes += generator.text(
        chars == 42? ProjectData.billFooter_42 : ProjectData.billFooter,
        styles: PosStyles(align: PosAlign.center,
          bold: true, height: PosTextSize.size2,
          width: PosTextSize.size2,),
      );
      bytes += generator.text(
        ProjectData.billFooter1,
        styles: PosStyles(align: PosAlign.center),
      );


      bytes += generator.cut();

      // ------------------ SEND TO PRINTER ------------------
      final result = await WindowsRawPrinter.printRawData(
        printerName: defaultPrinter,
        data: Uint8List.fromList(bytes),
      );

      print("PRINT RESULT: $result");
      return result;
    } catch (e, st) {
      print("❌ PRINT ERROR: $e\n$st");
      return false;
    }
  }

  String getDefaultPrinter() {
    // final needed = calloc<Uint32>();
    //
    // // 1. First call → get required buffer size
    // GetDefaultPrinter(nullptr, needed);
    //
    // if (needed.value == 0) {
    //   calloc.free(needed);
    //   return "";
    // }
    //
    // // 2. Allocate Uint16 buffer
    // final Pointer<Uint16> rawBuffer = calloc<Uint16>(needed.value);
    //
    // // 3. Cast to Utf16 pointer (this fixes your error)
    // final Pointer<Utf16> utf16Buffer = rawBuffer.cast<Utf16>();
    //
    // // 4. Second call → get actual printer name
    // if (GetDefaultPrinter(utf16Buffer, needed) == 0) {
    //   calloc.free(rawBuffer);
    //   calloc.free(needed);
    //   return "";
    // }
    //
    // // 5. Convert UTF16 → Dart string
    // final printerName = utf16Buffer.toDartString();
    //
    // calloc.free(rawBuffer);
    // calloc.free(needed);
    //
    // return printerName;
    return "";
  }

  Future<bool> printCustomBill(BuildContext context, {required OrderData data}) async {
    try {
      if (!context.mounted) return false;

      final printers = WindowsRawPrinter.listPrinters();
      if (printers.isEmpty) {
        print("❌ No printers found");
        return false;
      }
      final defaultPrinter = getDefaultPrinter();
      final profile = await CapabilityProfile.load();
      final generator = Generator(detectPaperSize(defaultPrinter), profile);
      List<int> bytes = [];

      // ------------------ LOGO (Optional) ------------------
      try {
        final logoBytes =
        (await rootBundle.load('assets/images/mart1.png')).buffer.asUint8List();

        final decoded = img.decodeImage(logoBytes);

        if (decoded != null) {
          final resized = img.copyResize(
            decoded,
            width: 280, // mm58, so little smaller
            height: 80,
          );

          bytes += generator.imageRaster(
            resized,
            align: PosAlign.center,

          );
          // bytes += generator.emptyLines(1);
        }
      } catch (e) {
        print("❌ Logo print failed: $e");
      }

      // ------------------ BUSINESS DETAILS ------------------


      bytes += generator.text(
        ProjectData.billAddress.replaceAll("\n", " "),
        styles: PosStyles(align: PosAlign.center,fontType: PosFontType.fontB),
      );


      bytes += generator.text(
        ProjectData.billMobile,
        styles: PosStyles(align: PosAlign.center,fontType: PosFontType.fontB),
      );

      // ------------------ BILL DETAILS ------------------
      final created =
          DateTime.tryParse(data.createdTs.toString()) ?? DateTime.now();

      // Bill No + Date
      int chars = detectCharPerLine(defaultPrinter);
      bytes += generator.row([
        PosColumn(
          text: "Bill No : ${data.invoiceNo}",
          width: chars == 42? 5 : 6,
          styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: "Dt: ${DateFormat('dd-MM-yyyy').format(created)}/${DateFormat('h:mm a').format(created)}",
          width: chars == 42? 7 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);
      final name = (data.name ?? '').toString().trim();
      final mobile = (data.mobile ?? '').toString().trim();
      final address = (data.address ?? '').toString().trim();

      bytes += generator.row([
        PosColumn(
          text: "Mobile  : $mobile",
          width: 6,
          styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: "Name : $name",
          width: 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text:   "Address : $address",
          width: 6,
          styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: "",
          width: 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.hr();

      // ------------------ ITEMS TABLE HEADER ------------------

      bytes += generator.row([
        PosColumn(
            text: "Product",
            width: chars == 42? 3 : 4,
            styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB)),
        PosColumn(
            text: "Qty",
            width: chars == 42? 3 : 2,
            styles: PosStyles(bold: true, align: PosAlign.center,fontType: PosFontType.fontB)),
        PosColumn(
            text: "MRP",
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB)),
        PosColumn(
            text: "Rate",
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB)),
        PosColumn(
            text: "Total",
            width: 2,
            styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB)),
      ]);
      bytes += generator.hr();

      // ------------------ ITEMS ------------------
      final products = data.productTitles?.split("||") ?? [];
      final qtys = data.productQuantity?.split("||") ?? [];
      final mrps = data.productMrp?.split("||") ?? [];
      final rates = data.productOutPrice?.split("||") ?? [];
      final units = data.productUnit?.split("||") ?? [];

      final int length = [
        products.length,
        qtys.length,
        mrps.length,
        rates.length,
        units.length,
      ].reduce((value, element) => value < element ? value : element);

      for (int i = 0; i < length; i++) {//normal
    //  for (int i = length - 1; i >= 0; i--) { //reverse

        final product = products[i];
        final qtyStr = qtys[i];
        final mrpStr = mrps[i];
        final rateStr = rates[i];
        final unit = units[i];

        final qty = double.tryParse(qtyStr) ?? 0;
        final mrp = double.tryParse(mrpStr) ?? 0;
        final rate = double.tryParse(rateStr) ?? 0;
        final double totalLine = unit.contains('Loose')
            ? rate * (qty / 1000)
            : rate * qty;




        //  String displayQty = qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
        String displayQty = unit.contains('Loose')
            ? (qty / 1000).toStringAsFixed(3) // grams → kg
            : qty.toInt().toString();

        bytes += generator.row([PosColumn(
            text: (unit.contains('Loose')) ? "$product-L" : "$product $unit",
            width: chars == 42? 3 : 4,
            styles: PosStyles(align: PosAlign.left,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: displayQty,
            width: chars == 42? 3 : 2,
            styles:(unit.contains('Loose'))? PosStyles(align: PosAlign.right,fontType: PosFontType.fontB): PosStyles(align: PosAlign.center,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: mrp.toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: rate.toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
          PosColumn(
            text: totalLine.toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
          ),
        ]);
      }

      bytes += generator.hr();

      // ------------------ TOTALS ------------------
      final totalQty = List.generate(qtys.length, (i) {
        final double value = double.tryParse(qtys[i]) ?? 0;
        final bool isLoose = units[i].toLowerCase().contains('loose');
        return isLoose ? 1.0 : value; // Loose product always counts as 1
      }).fold<double>(0, (prev, e) => prev + e);

      String displayQty = totalQty.toInt().toString(); // Always integer


      final grandTotal = double.tryParse(data.oTotal.toString()) ?? 0.0;
      bytes += generator.row([
        PosColumn(
          text:
          "Items: ${products.length}",
          width: chars == 42? 3 : 2,
          styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text:
          "Qty: $displayQty",

          width:chars == 42? 7 : 3,
          styles: PosStyles(bold: true, align: chars == 42? PosAlign.left : PosAlign.right,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text:"",
          width: chars == 42? 2 : 7,
          styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text:"",
          width:2,
          styles: PosStyles(bold: true, align: PosAlign.left,fontType: PosFontType.fontB),
        ),
        PosColumn(
          text: "Grand Total:",
          width: 5,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
          ),
        ),
        PosColumn(
          text: "${grandTotal.toStringAsFixed(2)}",
          width: 5,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size2,
          ),
        ),
      ]);

      // ------------------ PAYMENT ------------------
      final received = double.tryParse(data.receivedAmt.toString()) ?? 0.0;
      double payback = received - grandTotal;
      if (payback < 0) payback = 0;
      bytes += generator.row([
        PosColumn(text: "Received:", width: chars == 42? 5 : 3),
        PosColumn(
          text: received.toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),PosColumn(
          text: "",
          width: chars == 42? 4 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: "Payback:", width: chars == 42? 5 : 3),
        PosColumn(
          text: payback.toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),PosColumn(
          text: "",
          width: chars == 42? 4 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: "Total Gst: 18 %",
          width: chars == 42? 5 : 3,
          styles: PosStyles(bold: true,fontType: PosFontType.fontB,),
        ),
        PosColumn(
          text: "0.00", // unga GST value vechukonga
          width: 3,
          styles: PosStyles(bold: true, align: PosAlign.right,fontType: PosFontType.fontB,),
        ),PosColumn(
          text: "",
          width: chars == 42? 4 : 6,
          styles: PosStyles(align: PosAlign.right,fontType: PosFontType.fontB),
        ),
      ]);
      // ------------------ SAVINGS ------------------
      final savings = (data.savings == null ||
          data.savings.toString().isEmpty)
          ? 0.0
          : double.tryParse(data.savings.toString()) ?? 0.0;

      bytes += generator.hr();
      bytes += generator.text(
        "Your Savings : ${savings.toStringAsFixed(2)}",
        styles: PosStyles(
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
          align: PosAlign.center,
        ),
      );
      bytes += generator.hr();

      // ------------------ FOOTER ------------------
      bytes += generator.text(
        chars == 42? ProjectData.billFooter_42 : ProjectData.billFooter,
        styles: PosStyles(align: PosAlign.center,
          bold: true, height: PosTextSize.size2,
          width: PosTextSize.size2,),
      );
      bytes += generator.text(
        ProjectData.billFooter1,
        styles: PosStyles(align: PosAlign.center),
      );

      bytes += generator.cut();

      // ------------------ SEND TO PRINTER ------------------
      final result = await WindowsRawPrinter.printRawData(
        printerName: defaultPrinter,
        data: Uint8List.fromList(bytes),
      );

      print("PRINT RESULT: $result");
      return result;
    } catch (e, st) {
      print("❌ PRINT ERROR: $e\n$st");
      return false;
    }
  }

  double safeDouble(value) {
    if (value == null) return 0.0;
    if (value.toString().trim().isEmpty) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

}

class _ImageColumn {
  final String text;
  final int width;
  final PosAlign align;

  _ImageColumn({
    required this.text,
    required this.width,
    this.align = PosAlign.left,
  });
}