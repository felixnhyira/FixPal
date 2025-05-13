import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;


class DateFormatter {
  // Format full date with ordinal (e.g., 12th May 2025 or 12 mai 2025)
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final day = getDayWithSuffix(date.day);
    final monthFormat = DateFormat('MMMM'); // localized month name
    final yearFormat = DateFormat('yyyy');

    final month = monthFormat.format(date);
    final year = yearFormat.format(date);

    return '$day $month $year';
  }

  // Helper to add ordinal suffix to day
  static String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  // Format date-time (localized)
  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd hh:mm a').format(date);
  }

  // Format relative time (e.g., "2 hours ago", "in 3 days")
  static String formatRelativeTime(DateTime? date) {
    if (date == null) return 'N/A';

    // Set locale for timeago (optional, defaults to English)
    timeago.setLocaleMessages('fr', timeago.FrMessages()); // example for French
    timeago.setLocaleMessages('es', timeago.EsMessages()); // Spanish

    final locale = Intl.getCurrentLocale()?.substring(0, 2) ?? 'en';
    return timeago.format(date, locale: locale);
  }
}