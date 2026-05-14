import 'package:decimal/decimal.dart';

Decimal toDecimal(String value) {
  return Decimal.parse(value);
}

double toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
