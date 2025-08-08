import 'package:flutter/services.dart';

final InputFormatters constInputFormatters = InputFormatters._();

class InputFormatters {
  InputFormatters._();

  final List<TextInputFormatter> mobileNumberInput = [
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  ];

  final List<TextInputFormatter> dateInput = [
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
  ];

  final List<TextInputFormatter> emailInput = [
    LengthLimitingTextInputFormatter(80),
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9@.]"))
  ];

  final List<TextInputFormatter> socialInput = [
    LengthLimitingTextInputFormatter(30),
    FilteringTextInputFormatter.allow(
        RegExp("[a-zA-Z0-9 _/. !@#%^&*()/?:;+=_-]"))
    //FilteringTextInputFormatter.allow(RegExp(r'[^,]*'))
  ];

  final List<TextInputFormatter> aadharInput = [
    LengthLimitingTextInputFormatter(12),
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  ];

  final List<TextInputFormatter> panInput = [
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
  ];

  final List<TextInputFormatter> pinCodeInput = [
    LengthLimitingTextInputFormatter(6),
    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  ];

  final List<TextInputFormatter> numberInput = [
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  ];

  final List<TextInputFormatter> accNoInput = [
    LengthLimitingTextInputFormatter(15),
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
  ];

  final List<TextInputFormatter> ifscInput = [
    LengthLimitingTextInputFormatter(11),
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
  ];

  final List<TextInputFormatter> numTextInput = [
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
  ];

  final List<TextInputFormatter> textInput = [
    LengthLimitingTextInputFormatter(200),

    //UpperCaseTextFormatter(),
    FilteringTextInputFormatter.allow(
        RegExp("[a-zA-Z0-9 _/. !@#%^&*()/?:;+=_-]"))
  ];

  final List<TextInputFormatter> addressInput = [
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9/. ]"))
  ];

  final List<TextInputFormatter> address2Input = [
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
  ];
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}
