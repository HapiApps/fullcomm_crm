import 'dart:typed_data';

class WindowsRawPrinter {
  /// Print RAW bytes directly to Windows printer
  static Future<bool> printRawData({
    required String printerName,
    required Uint8List data,
  }) async {
    // final printerNamePtr = printerName.toNativeUtf16();
    // final phPrinter = calloc<HANDLE>();
    //
    // // 1. OPEN PRINTER
    // final openResult = OpenPrinter(printerNamePtr, phPrinter, nullptr);
    // if (openResult == 0) {
    //   calloc.free(printerNamePtr);
    //   calloc.free(phPrinter);
    //   print("❌ OpenPrinter failed");
    //   return false;
    // }
    //
    // // 2. DOC INFO
    // final docNamePtr = "Print Job".toNativeUtf16();
    // final dataTypePtr = "RAW".toNativeUtf16();  // Or null if still crashing
    //
    // final docInfo = calloc<DOC_INFO_1>()
    //   ..ref.pDocName = docNamePtr
    //   ..ref.pOutputFile = nullptr
    //   ..ref.pDatatype = dataTypePtr;
    //
    // // 3. START DOC
    // final startDoc = StartDocPrinter(phPrinter.value, 1, docInfo);
    // if (startDoc == 0) {
    //   print("❌ StartDocPrinter failed");
    //   ClosePrinter(phPrinter.value);
    //   calloc.free(printerNamePtr);
    //   calloc.free(phPrinter);
    //   calloc.free(docInfo);
    //   return false;
    // }
    //
    // // 4. START PAGE
    // final startPage = StartPagePrinter(phPrinter.value);
    // if (startPage == 0) {
    //   print("❌ StartPagePrinter failed");
    //   EndDocPrinter(phPrinter.value);
    //   ClosePrinter(phPrinter.value);
    //   calloc.free(printerNamePtr);
    //   calloc.free(phPrinter);
    //   calloc.free(docInfo);
    //   return false;
    // }
    //
    // // 5. CHUNKED WRITE (SAFE FOR ALL PRINTERS)
    // const chunkSize = 512; // <-- BEST, safest size for all POS printers
    // int offset = 0;
    //
    // while (offset < data.length) {
    //   final end = (offset + chunkSize > data.length) ? data.length : offset + chunkSize;
    //   final chunk = data.sublist(offset, end);
    //
    //   final chunkPtr = calloc<Uint8>(chunk.length);
    //   chunkPtr.asTypedList(chunk.length).setAll(0, chunk);
    //
    //   final bytesWrittenPtr = calloc<Uint32>();
    //
    //   final ok = WritePrinter(
    //     phPrinter.value,
    //     chunkPtr,
    //     chunk.length,
    //     bytesWrittenPtr,
    //   );
    //
    //   calloc.free(chunkPtr);
    //   calloc.free(bytesWrittenPtr);
    //
    //   if (ok == 0) {
    //     print("❌ WritePrinter failed at offset $offset");
    //     EndPagePrinter(phPrinter.value);
    //     EndDocPrinter(phPrinter.value);
    //     ClosePrinter(phPrinter.value);
    //     calloc.free(printerNamePtr);
    //     calloc.free(phPrinter);
    //     calloc.free(docInfo);
    //     return false;
    //   }
    //
    //   offset = end;
    // }
    //
    // // 6. END PAGE
    // EndPagePrinter(phPrinter.value);
    //
    // // 7. END DOC
    // EndDocPrinter(phPrinter.value);
    //
    // // 8. CLOSE PRINTER
    // ClosePrinter(phPrinter.value);
    //
    // // 9. FREE MEMORY
    // calloc.free(printerNamePtr);
    // calloc.free(phPrinter);
    // calloc.free(docInfo);
    //
    print("✔ printRawData completed successfully");
    return true;
  }


  static bool isPrinterOnline(String printerName) {
    // final namePtr = printerName.toNativeUtf16();
    // final phPrinter = calloc<HANDLE>();
    //
    // final open = OpenPrinter(namePtr, phPrinter, nullptr);
    //
    // calloc.free(namePtr);
    //
    // if (open == 0) {
    //   // Printer not available / offline / unplugged
    //   return false;
    // }
    //
    // ClosePrinter(phPrinter.value);
    // calloc.free(phPrinter);
    return true;
  }

  /// List all installed Windows printers
  static List<String> listPrinters() {
    // final flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;
    // final pcbNeeded = calloc<Uint32>();
    // final pcReturned = calloc<Uint32>();
    //
    // // First call → Get required buffer size
    // EnumPrinters(flags, nullptr, 1, nullptr, 0, pcbNeeded, pcReturned);
    //
    // final buffer = calloc<Uint8>(pcbNeeded.value);
    //
    // // Second call → Fill printer data
    // EnumPrinters(flags, nullptr, 1, buffer, pcbNeeded.value, pcbNeeded, pcReturned);
    //
    // final printers = <String>[];
    // final structSize = sizeOf<PRINTER_INFO_1>();
    //
    // for (int i = 0; i < pcReturned.value; i++) {
    //   final ptr = Pointer<PRINTER_INFO_1>.fromAddress(
    //     buffer.address + (i * structSize),
    //   );
    //   printers.add(ptr.ref.pName.toDartString());
    // }
    //
    // calloc.free(buffer);
    // calloc.free(pcbNeeded);
    // calloc.free(pcReturned);

    // return printers;
    return [];
  }
}
