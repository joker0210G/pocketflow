import 'package:intl/intl.dart';

extension DateFormatter on DateTime {
  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(this);
  }

  String get formattedTime {
    return DateFormat('jm').format(this);
  }
}

extension CurrencyFormatter on double {
  String get toCurrency {
    return NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(this);
  }
}
