import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMMM d, y');
  static final DateFormat _shortDateFormat = DateFormat('EEE');
  static final DateFormat _dayFormat = DateFormat('d');
  static final DateFormat _monthDayFormat = DateFormat('MMM d');

  static String formatFullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String formatDay(DateTime date) {
    return _dayFormat.format(date);
  }

  static String formatMonthDay(DateTime date) {
    return _monthDay.format(date);
  }

  static String getGreeting(DateTime date) {
    final hour = date.hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static String getRelativeDay(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return formatShortDate(date);
    }
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static List<DateTime> getCurrentWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    return List.generate(7, (index) {
      return DateTime(monday.year, monday.month, monday.day + index);
    });
  }
}
