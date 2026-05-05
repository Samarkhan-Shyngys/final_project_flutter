import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'ru_RU', symbol: '₸', decimalDigits: 0);
final _number   = NumberFormat('#,###', 'ru_RU');

/// 1 234 500 ₸
String formatCurrency(num value) => _currency.format(value);

/// 1 234 500
String formatNumber(num value) => _number.format(value);

/// 1 234 тыс.₸
String formatThousands(num value) => '${_number.format(value ~/ 1000)} тыс.₸';
