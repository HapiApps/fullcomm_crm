@JS()
library ocr_web_helper;

import 'package:js/js.dart';
import 'dart:js_util';

@JS('readTextFromImage')
external Object _readTextFromImage(String base64Image);

Future<String> readTextFromImage(String base64Image) async {
  final jsPromise = _readTextFromImage(base64Image);

  // Promise → Future convert
  final result = await promiseToFuture(jsPromise);

  return result.toString();
}