import 'package:flutter/services.dart';

class InputFormatters{
  
  static List<TextInputFormatter> mobileNumberInput=[
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  ];
  static List<TextInputFormatter> passwordInput = [
    LengthLimitingTextInputFormatter(16),
    FilteringTextInputFormatter.deny(RegExp(r'\s')), // Prevents spaces
  ];
  static List<TextInputFormatter> quantityInput=[
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  ];

  static List<TextInputFormatter> variationInput = [
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    _SingleDotFormatter(),
  ];
  static List<TextInputFormatter> pinCodeInput=[
    LengthLimitingTextInputFormatter(6),
    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  ];


}

class _SingleDotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    // allow only one dot
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    return newValue;
  }
}
