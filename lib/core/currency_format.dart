import 'package:intl/intl.dart';

class CurrencyFormat {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String format(double value) {
    return _formatter.format(value);
  }

  static double? parseFromText(String text) {
    // Remove currency symbols and normalize decimal separator
    String normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[r\$\s]'), '')
        .replaceAll(',', '.');
    
    try {
      return double.parse(normalized);
    } catch (e) {
      return null;
    }
  }
}