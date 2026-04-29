import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(time);
  }

  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    return phone; // Return original if format doesn't match
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatQuantity(int quantity) {
    return NumberFormat.decimalPattern().format(quantity);
  }

  static String formatPercentage(double percentage) {
    final formatter = NumberFormat.percentPattern();
    formatter.minimumFractionDigits = 1;
    formatter.maximumFractionDigits = 1;
    return formatter.format(percentage / 100);
  }
}
