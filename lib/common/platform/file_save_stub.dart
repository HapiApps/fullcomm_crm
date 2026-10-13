import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> saveBytes(String fileName, Uint8List bytes) async {
  await FilePicker.platform.saveFile(
    dialogTitle: 'Save file',
    fileName: fileName,
    bytes: bytes,
  );
}