import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/mood_tracker/insights_page.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'calendar_utils.dart';

class CalendarMonth extends StatelessWidget {
  static const StartingDayOfWeek startingDayOfWeek = StartingDayOfWeek.monday;
  static const double monthNamePadding = 24;
  static const double dayBoxPadding = 8;

  final CalendarMonthData monthData;
  final ValueChanged<DateTime> onDaySelected;

  CalendarMonth({
    @required this.monthData,
    @required this.onDaySelected,
  });

  DateTime get monthDate => monthData.firstDay;

  List<CalendarDayData> get days => monthData.days;

  double getCellDimension(BuildContext context) =>
      (MediaQuery.of(context).size.width - InsightsPage.daysRowsHorizontalPadding * 2) / DateTime.daysPerWeek;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          monthName,
          ColumnSeparator.small,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: SeparatorLine(),
          ),
          ColumnSeparator.small,
          ...getDaysRows(context),
          ColumnSeparator.veryBig,
        ],
      );

  Widget get monthName => Padding(
        padding: EdgeInsets.only(left: monthNamePadding),
        child: TextScaled(
          DateFormat('MMMM').format(monthDate),
          style: AppTextStyles.h5ZirkonRegular.copyWith(
            fontSize: defaultPadding,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      );

  List<Widget> getDaysRows(
    BuildContext context,
  ) {
    final List<Widget> rows = List<Widget>();
    int startingDay = 0;
    while (startingDay < days.length) {
      rows.add(buildDaysRow(context, startingDay));
      startingDay += DateTime.daysPerWeek;
    }
    return rows;
  }

  Widget buildDaysRow(BuildContext context, int startingDay) => Padding(
        padding: EdgeInsets.symmetric(horizontal: InsightsPage.daysRowsHorizontalPadding, vertical: 8),
        child: Column(
          children: <Widget>[
            Row(
              children: days.skip(startingDay).take(DateTime.daysPerWeek).map((day) => buildDayCell(day)).toList(),
            ),
            Row(
              children:
                  days.skip(startingDay).take(DateTime.daysPerWeek).map((day) => buildDayNumber(context, day)).toList(),
            ),
          ],
        ),
      );

  Widget buildDayCell(CalendarDayData day) {
    VoidCallback onTap = onDaySelected == null ? null : () => onDaySelected(day.date);

    return Builder(
      builder: (context) => Container(
        width: getCellDimension(context),
        height: getCellDimension(context),
        padding: EdgeInsets.all(dayBoxPadding),
        child: day.date.month != monthDate.month
            ? Container()
            : GestureDetector(
                onTap: onTap,
                child: DayCell(
                  day: day,
                ),
              ),
      ),
    );
  }

  Widget buildDayNumber(BuildContext context, CalendarDayData day) => Container(
        width: getCellDimension(context),
        alignment: Alignment.bottomCenter,
        child: day.date.month != monthDate.month
            ? Container()
            : TextScaled(
                "${day.date.day}",
                style: AppTextStyles.captionZirkonRegular.copyWith(
                    color: App.isDayBreak ? AppTextStyles.captionZirkonRegular.color : Colors.white.withOpacity(0.8)),
              ),
      );
}

class DayCell extends StatelessWidget {
  static const double _indicatorBarHeightRatio = 0.09;
  final CalendarDayData day;

  const DayCell({
    @required this.day,
  });

  EdgeInsets getIndicatorPadding(double barHeight, double averageMoodValue) {
    if (averageMoodValue == null) {
      return EdgeInsets.only(top: 0, bottom: barHeight * (1 - _indicatorBarHeightRatio));
    }

    double availableHeightRatio = 1.0 - _indicatorBarHeightRatio;
    double heightStepRatio = availableHeightRatio / (Moods.highestValue * 2);
    double topPaddingRatio = heightStepRatio * (Moods.highestValue - averageMoodValue);

    /// Clamp because floating point precision issues can make bottomPaddingRatio negative bit 10e-17 something and negative padding is not supported.
    double bottomPaddingRatio = (1.0 - topPaddingRatio - _indicatorBarHeightRatio).clamp(0.0, 1.0);

    return EdgeInsets.only(
      top: barHeight * topPaddingRatio,
      bottom: barHeight * bottomPaddingRatio,
    );
  }

  Widget getBar(double averageMoodValue) => Expanded(
        child: Stack(
          children: <Widget>[
            Container(color: App.isDayBreak ? AppColors.baseColor.withOpacity(0.18) : Colors.white.withOpacity(0.12)),
            if (averageMoodValue != null)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) => Padding(
                    padding: getIndicatorPadding(constraints.biggest.height, averageMoodValue),
                    child: Container(color: App.isDayBreak ? AppColors.accentColor : AppColors.whiteFaded),
                  ),
                ),
              )
          ],
        ),
      );

  Widget get emptySpace => Container(width: 1);

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          getBar(day.startOfDayAverageMoodValue),
          emptySpace,
          getBar(day.middleOfDayAverageMoodValue),
          emptySpace,
          getBar(day.endOfDayAverageMoodValue),
        ],
      );
}

@immutable
class CalendarMonthData {
  /// Date of the first day of the month being displayed. Not always the same as [days.first] since [days] also have the days of the previous month that are part of the first week of the month.
  final DateTime firstDay;

  /// Needs to have all of the days of the month and the days of the previous and following month that are common to
  /// the first and last weeks.
  final List<CalendarDayData> days;

  CalendarMonthData(this.firstDay, this.days);
}

@immutable
class CalendarDayData {
  final DateTime date;
  final double startOfDayAverageMoodValue;
  final double middleOfDayAverageMoodValue;
  final double endOfDayAverageMoodValue;

  CalendarDayData(
    this.date,
    this.startOfDayAverageMoodValue,
    this.middleOfDayAverageMoodValue,
    this.endOfDayAverageMoodValue,
  );
}
