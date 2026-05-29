// João Pedro Panza Mainieri - 25006642;
import 'package:intl/intl.dart';

final formatter = NumberFormat.compact();
final moneyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _thousandFormatter = NumberFormat.compactCurrency(
  locale: 'pt_BR',
  symbol: 'R\$',
);

String formatMoney(double num) {
  if (num >= 1000) {
    return _thousandFormatter.format(num);
  } else {
    return moneyFormatter.format(num);
  }
}
