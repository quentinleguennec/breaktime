import 'dart:ui';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/bloc_pattern/bloc_provider.dart';
import 'package:aebeze/mood_tracker/widgets/weekly_checkins/weekly_checkins_insights_bloc.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WeeklyCheckinsInsights extends StatelessWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;

  const WeeklyCheckinsInsights({@required this.margin, @required this.padding});

  Widget getHeader(BuildContext context, int thisWeekCheckinsCount, int lastWeekCheckinsCount) {
    String bodyText = "";
    if (thisWeekCheckinsCount == 0) {
      bodyText =
          "${localize(context, "checkins_header_no_entry_start")} ${App.appName} ${localize(context, "checkins_header_no_entry_end")}";
    } else {
      String moreLessSame = "";
      if (thisWeekCheckinsCount > lastWeekCheckinsCount) {
        moreLessSame = localize(context, "insights_more");
      } else if (thisWeekCheckinsCount == lastWeekCheckinsCount) {
        moreLessSame = localize(context, "insights_same");
      } else {
        moreLessSame = localize(context, "insights_less");
      }
      bodyText =
          "${localize(context, "checkins_header_start")} ${App.appName} $moreLessSame ${localize(context, "checkins_header_end")}";

      if (thisWeekCheckinsCount > lastWeekCheckinsCount) {
        bodyText = "$bodyText ${localize(context, "checkins_header_additional_great_work")}";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextScaled(
          localize(context, "checkins"),
          style: AppTextStyles.h5ZirkonRegular.copyWith(color: Colors.white),
        ),
        ColumnSeparator.small,
        TextScaled(
          bodyText,
          style: AppTextStyles.bodyZirkonRegular.copyWith(color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<WeeklyCheckinsInsightsState>(
        stream: BlocProvider.of<WeeklyCheckinsInsightsBloc>(context).stream,
        builder: (context, AsyncSnapshot<WeeklyCheckinsInsightsState> snapshot) => Container(
          margin: margin,
          padding: padding,
          decoration: AppDecorations.transparentBox,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getHeader(
                context,
                snapshot.data?.thisWeekCheckinsCount ?? 0,
                snapshot.data?.lastWeekCheckinsCount ?? 0,
              ),
              ColumnSeparator.medium,
              const SeparatorLine(),
              ColumnSeparator.medium,
              _CheckinsCounts(
                countThisWeek: snapshot.data?.thisWeekCheckinsCount ?? 0,
                countLastWeek: snapshot.data?.lastWeekCheckinsCount ?? 0,
              ),
              ColumnSeparator.big,
              Container(
                width: MediaQuery.of(context).size.width,
                height: 130,
                child: _Graph(
                  lastWeekValues: snapshot.data?.lastWeekValues,
                  thisWeekValues: snapshot.data?.thisWeekValues,
                  maxValue: snapshot.data?.maxValue,
                ),
              ),
            ],
          ),
        ),
      );
}

class _CheckinsCounts extends StatelessWidget {
  final int countThisWeek;
  final int countLastWeek;

  const _CheckinsCounts({
    @required this.countThisWeek,
    @required this.countLastWeek,
  });

  Widget getCount(
    BuildContext context,
    Color color,
    String headerText,
    int count,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 7),
              TextScaled(
                headerText,
                style: AppTextStyles.h7ZirkonRegular.copyWith(color: color),
              ),
            ],
          ),
          ColumnSeparator.tiny,
          TextScaled(
            "$count ${localize(context, "checkins_count")}",
            style: AppTextStyles.h5ZirkonRegular.copyWith(color: color),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: getCount(
              context,
              App.isDayBreak ? AppColors.accentColor : AppColors.whiteFaded,
              localize(context, "checkins_this_week"),
              countThisWeek,
            ),
          ),
          Expanded(
            flex: 1,
            child: getCount(
              context,
              App.isDayBreak ? AppColors.insightsWidgetGrey : Colors.white.withOpacity(0.6),
              localize(context, "checkins_last_week"),
              countLastWeek,
            ),
          ),
        ],
      );
}

class _Graph extends StatelessWidget {
  static const int maxPointsCount = 7;
  static const double horizontalPadding = 5;

  final List<double> lastWeekValues;
  final List<double> thisWeekValues;
  final double maxValue;

  _Graph({
    @required this.lastWeekValues,
    @required this.thisWeekValues,
    @required this.maxValue,
  });

  bool get isLastWeekDataAvailable => maxValue != null && (lastWeekValues != null && lastWeekValues.isNotEmpty);

  bool get isThisWeekDataAvailable => maxValue != null && (thisWeekValues != null && thisWeekValues.isNotEmpty);

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _GraphFramePainter(
          pointsCount: lastWeekValues?.length ?? 0,
          maxPointsCount: maxPointsCount,
        ),
        foregroundPainter: !isLastWeekDataAvailable && !isThisWeekDataAvailable
            ? null
            : _GraphLinesPainter(
                lines: [
                  if (isLastWeekDataAvailable)
                    _GraphLineData(
                      values: lastWeekValues,
                      color: App.isDayBreak ? AppColors.insightsWidgetGrey : Color(0xFFFFFFFF).withOpacity(0.6),
                    ),
                  if (isThisWeekDataAvailable)
                    _GraphLineData(
                      values: thisWeekValues,
                      color: App.isDayBreak ? AppColors.accentColor : Color(0xF2FFFFFF),
                    ),
                ],
                maxValue: maxValue,
                maxPointsCount: maxPointsCount,
              ),
      );
}

@immutable
class _GraphLineData {
  final List<double> values;
  final Color color;

  _GraphLineData({
    @required this.values,
    @required this.color,
  });
}

class _GraphLinesPainter extends CustomPainter {
  static const double lineEndPointRadius = 4;
  static const double yOriginOffset = 10 + _GraphFramePainter.xMarkHeight;

  final List<_GraphLineData> lines;
  final double maxValue;
  final int maxPointsCount;
  final Paint linePaint = Paint()
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.butt
    ..style = PaintingStyle.fill;
  final Paint endPointPaint = Paint()..style = PaintingStyle.fill;

  _GraphLinesPainter({
    @required this.lines,
    @required this.maxValue,
    @required this.maxPointsCount,
  }) : assert(maxPointsCount >= 2);

  @override
  void paint(Canvas canvas, Size size) {
    final double availableHeight = size.height - yOriginOffset - lineEndPointRadius;
    final double availableWidth = size.width - (_Graph.horizontalPadding * 2);
    final double xUnit = availableWidth / (maxPointsCount - 1);
    final double yUnit = availableHeight / maxValue;

    lines.forEach((line) {
      drawLine(canvas, size, xUnit, yUnit, line);
      drawLineEndPoint(canvas, size, xUnit, yUnit, line);
    });
  }

  Offset getPointPosition(
    Size size,
    double xUnit,
    double yUnit,
    _GraphLineData line,
    int pointIndex,
  ) =>
      Offset(
        _Graph.horizontalPadding + xUnit * pointIndex,
        size.height - (_GraphLinesPainter.yOriginOffset + yUnit * line.values[pointIndex]),
      );

  void drawLine(Canvas canvas, Size size, double xUnit, double yUnit, _GraphLineData line) {
    if (line.values.length < 2) {
      /// Not enough points to draw lines.
      return;
    }

    linePaint.color = line.color;
    for (int i = 0; i < line.values.length - 2; i++) {
      canvas.drawLine(
        getPointPosition(size, xUnit, yUnit, line, i),
        getPointPosition(size, xUnit, yUnit, line, i + 1),
        linePaint,
      );
    }

    /// Last segment must be a bit smaller to avoid overlap with the end point circle.
    Offset endPoint = getPointPosition(size, xUnit, yUnit, line, line.values.length - 1);
    endPoint = Offset(endPoint.dx - lineEndPointRadius, endPoint.dy);
    canvas.drawLine(
      getPointPosition(size, xUnit, yUnit, line, line.values.length - 2),
      endPoint,
      linePaint,
    );
  }

  void drawLineEndPoint(Canvas canvas, Size size, double xUnit, double yUnit, _GraphLineData line) {
    final Offset center = getPointPosition(size, xUnit, yUnit, line, line.values.length - 1);
    endPointPaint.color = line.color;
    canvas.drawCircle(center, lineEndPointRadius, endPointPaint);
  }

  @override
  bool shouldRepaint(_GraphLinesPainter other) => lines != other.lines || maxValue != other.maxValue;
}

class _GraphFramePainter extends CustomPainter {
  static const double xMarkHeight = 4;
  final int pointsCount;
  final int maxPointsCount;
  final Paint xMarksPaint = Paint()
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.fill
    ..color = AppColors.insightsWidgetGrey.withOpacity(0.5);

  _GraphFramePainter({
    @required this.pointsCount,
    @required this.maxPointsCount,
  }) : assert(maxPointsCount >= 2);

  @override
  void paint(Canvas canvas, Size size) {
    final double availableWidth = size.width - (_Graph.horizontalPadding * 2);
    final double xUnit = availableWidth / (maxPointsCount - 1);
    drawXMarks(canvas, size, xUnit);
  }

  void drawXMarks(Canvas canvas, Size size, double xUnit) {
    for (int i = 0; i < maxPointsCount; i++) {
      canvas.drawLine(
        Offset(_Graph.horizontalPadding + xUnit * i, size.height),
        Offset(_Graph.horizontalPadding + xUnit * i, size.height - xMarkHeight),
        xMarksPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GraphFramePainter other) =>
      pointsCount != other.pointsCount || maxPointsCount != other.maxPointsCount;
}
