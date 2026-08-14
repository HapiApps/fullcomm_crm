import 'package:flutter/services.dart';

final InputFormatters constInputFormatters = InputFormatters._();

class InputFormatters {
  InputFormatters._();

  // final List<TextInputFormatter> mobileNumberInput = [
  //   LengthLimitingTextInputFormatter(10),
  //   FilteringTextInputFormatter.digitsOnly,
  //   FilteringTextInputFormatter.allow(RegExp("[0-9]"))
  // ];

  final List<TextInputFormatter> mobileNumberInput = [
    TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text;

      // Digits மட்டும்
      text = text.replaceAll(RegExp(r'\D'), '');

      // Paste செய்தால் +91 / 91 remove
      if (text.startsWith('91') && text.length > 10) {
        text = text.substring(2);
      }

      // 10 digits-க்கு மேல் type/paste செய்தால் first 10 மட்டும்
      if (text.length > 10) {
        text = text.substring(0, 10);
      }

      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }),
  ];

  final List<TextInputFormatter> fifteenChars = [
    LengthLimitingTextInputFormatter(15),
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
  ];
  final List<TextInputFormatter> decimalInput=[
    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
  ];
  final List<TextInputFormatter> passwordInput = [
    LengthLimitingTextInputFormatter(16)
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
    // LengthLimitingTextInputFormatter(30),
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
    LengthLimitingTextInputFormatter(10),
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
  final List<TextInputFormatter> textInput2 = [
    LengthLimitingTextInputFormatter(200),

    //UpperCaseTextFormatter(),
    FilteringTextInputFormatter.allow(
        RegExp("[a-zA-Z0-9 _/. !@#%^&*()/?:,;+=_-]"))
  ];

  final List<TextInputFormatter> addressInput = [
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9/. ]"))
  ];

  final List<TextInputFormatter> address2Input = [
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
  ];
}

// class UpperCaseTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     return TextEditingValue(
//       text: capitalize(newValue.text),
//       selection: newValue.selection,
//     );
//   }
// }

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {

    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}