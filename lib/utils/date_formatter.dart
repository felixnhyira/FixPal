import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final day = getDayWithSuffix(date.day);
    final monthFormat = DateFormat('MMMM');
    final yearFormat = DateFormat('yyyy');

    final month = monthFormat.format(date);
    final year = yearFormat.format(date);

    return '$day $month $year';
  }

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

  static String formatDaysLeft(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inHours < 0) {
      return 'Deadline passed';
    }

    final days = difference.inDays;

    if (days == 0) {
      return 'Less than a day left';
    } else if (days == 1) {
      return '1 day left';
    } else {
      return '$days days left';
    }
  }

  static Color getDeadlineColor(DateTime? date) {
    if (date == null) return Colors.grey;

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inHours <= 0) {
      return Colors.redAccent;
    } else if (difference.inDays < 2) {
      return Colors.orange;
    } else if (difference.inDays < 7) {
      return Colors.deepOrangeAccent;
    } else {
      return Colors.green;
    }
  }

  static String formatRelativeTime(DateTime? date) {
    if (date == null) return 'N/A';

    timeago.setLocaleMessages('fr', timeago.FrMessages());
    timeago.setLocaleMessages('es', timeago.EsMessages());

    final locale = Intl.getCurrentLocale()?.substring(0, 2) ?? 'en';
    return timeago.format(date, locale: locale);
  }
}