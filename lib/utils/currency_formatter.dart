// utils/currency_formatter.dart
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class CurrencyFormatter {
  static final CurrencyTextInputFormatter brl =
      CurrencyTextInputFormatter.currency(locale: 'pt_BR', symbol: 'R\$');
  static double getNumericValue() {
    return brl.getUnformattedValue().toDouble();
  }

  static double parseValue(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return 0;
    return int.parse(digits) / 100;
  }
}
