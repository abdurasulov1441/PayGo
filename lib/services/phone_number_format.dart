import 'dart:math';
import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (!newValue.text.startsWith('+998 ')) {
      return oldValue;
    }

    String text = newValue.text.substring(5).replaceAll(RegExp(r'\D'), '');

    if (text.length > 9) {
      text = text.substring(0, 9);
    }

    StringBuffer formatted = StringBuffer('+998 ');
    int selectionIndex = newValue.selection.baseOffset;

    if (text.isNotEmpty) {
      formatted.write('(${text.substring(0, min(2, text.length))}');
    }
    if (text.length > 2) {
      formatted.write(') ${text.substring(2, min(5, text.length))}');
    }
    if (text.length > 5) {
      formatted.write(' ${text.substring(5, min(7, text.length))}');
    }
    if (text.length > 7) {
      formatted.write(' ${text.substring(7, text.length)}');
    }

    selectionIndex = formatted.length;

    if (newValue.selection.baseOffset < 5) {
      selectionIndex = 5;
    }

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
