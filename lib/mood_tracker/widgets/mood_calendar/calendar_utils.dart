import 'package:date_utils/date_utils.dart';

/// Available day of week formats. `TableCalendar` will start the week with chosen day.
/// * `StartingDayOfWeek.monday`: Monday - Sunday
/// * `StartingDayOfWeek.sunday`: Sunday - Saturday
enum StartingDayOfWeek { monday, sunday }

class CalendarUtils {
  /// Returns a list of days for the month including the days of the week that ar part of the previous or following month (ready for [MoodCalendarMonth]).
  static List<DateTime> daysInMonth(DateTime month, {StartingDayOfWeek startingDayOfWeek = StartingDayOfWeek.monday}) {
    final first = Utils.firstDayOfMonth(month);
    final daysBefore = startingDayOfWeek == StartingDayOfWeek.sunday ? first.weekday % 7 : first.weekday - 1;
    var firstToDisplay = first.subtract(Duration(days: daysBefore));

    if (firstToDisplay.hour == 23) {
      firstToDisplay = firstToDisplay.add(Duration(hours: 1));
    }

    var last = Utils.lastDayOfMonth(month);

    if (last.hour == 23) {
      last = last.add(Duration(hours: 1));
    }

    var daysAfter = 7 - last.weekday;

    if (startingDayOfWeek == StartingDayOfWeek.sunday) {
      // If the last day is Sunday (7) the entire week must be rendered
      if (daysAfter == 0) {
        daysAfter = 7;
      }
    } else {
      daysAfter++;
    }

    var lastToDisplay = last.add(Duration(days: daysAfter));

    if (lastToDisplay.hour == 1) {
      lastToDisplay = lastToDisplay.subtract(Duration(hours: 1));
    }

    return Utils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  static List<DateTime> daysInWeek(DateTime week, {StartingDayOfWeek startingDayOfWeek = StartingDayOfWeek.monday}) {
    final first = firstDayOfWeek(week, startingDayOfWeek: startingDayOfWeek);
    final last = lastDayOfWeek(week, startingDayOfWeek: startingDayOfWeek);

    final days = Utils.daysInRange(first, last);
    return days.map((day) => DateTime(day.year, day.month, day.day)).toList();
  }

  static DateTime firstDayOfWeek(DateTime day, {StartingDayOfWeek startingDayOfWeek = StartingDayOfWeek.monday}) {
    day = DateTime.utc(day.year, day.month, day.day, 12);

    final decreaseNum = startingDayOfWeek == StartingDayOfWeek.sunday ? day.weekday % 7 : day.weekday - 1;
    return day.subtract(Duration(days: decreaseNum));
  }

  static DateTime lastDayOfWeek(DateTime day, {StartingDayOfWeek startingDayOfWeek = StartingDayOfWeek.monday}) {
    day = DateTime.utc(day.year, day.month, day.day, 12);

    final increaseNum = startingDayOfWeek == StartingDayOfWeek.sunday ? day.weekday % 7 : day.weekday - 1;
    return day.add(Duration(days: 7 - increaseNum));
  }

  static bool isToday(DateTime day) {
    return Utils.isSameDay(day, DateTime.now());
  }

  static bool isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }
}
