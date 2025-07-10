import 'package:flutter/services.dart';

class EnglishLowerCaseConstraintFormatter extends TextInputFormatter {
  final RegExp _upperCaseRegExp = RegExp(r'[A-Z]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAllMapped(
      _upperCaseRegExp,
      (match) => match.group(0)!.toLowerCase(),
    );

    return newValue.copyWith(text: newText, selection: newValue.selection);
  }
}
