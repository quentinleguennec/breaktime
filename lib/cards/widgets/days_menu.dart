import 'dart:math';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class DaysMenu extends StatelessWidget {
  static const double spaceBetweenButtons = 24;
  static const int numberOfButtonsPerRow = 4;

  final Treatment currentTreatment;
  final List<Treatment> allTreatments;
  final Map<String, Map<String, int>> completedTreatments;
  final ValueChanged<Treatment> onDaySelected;
  final int nextUncompletedDay;

  DaysMenu({
    @required this.currentTreatment,
    @required this.allTreatments,
    @required this.completedTreatments,
    @required this.onDaySelected,
  }) : nextUncompletedDay = _getNextUncompletedDay(completedTreatments[currentTreatment.type], allTreatments);

  static int _getNextUncompletedDay(Map<String, int> completedTreatmentsForType, final List<Treatment> allTreatments) {
    if (completedTreatmentsForType == null || completedTreatmentsForType.isEmpty) {
      return 1;
    }

    int highestCompletedDay = completedTreatmentsForType?.keys?.map((key) => int.tryParse(key) ?? 0)?.reduce(max) ?? 0;

    if (highestCompletedDay >= allTreatments.last.day) {
      return allTreatments.last.day;
    } else {
      return highestCompletedDay + 1;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextScaled(
            localize(context, "start_card_treatments").toUpperCase(),
            style: AppTextStyles.bodyZirkonRegular.copyWith(color: AppColors.baseColorFaded.withOpacity(0.9)),
          ),
          ColumnSeparator.tinyPlus,
          SeparatorLine.baseVeryFaded(),
          ColumnSeparator.medium,
          Wrap(
            spacing: spaceBetweenButtons,
            runSpacing: 24,
            children: allTreatments
                .map(
                  (treatment) => _DayButton(
                    day: treatment.day,
                    isCurrent: currentTreatment == treatment,
                    isCompleted: completedTreatments[treatment.type] != null &&
                        completedTreatments[treatment.type].containsKey(treatment.day.toString()),
                    isLocked: treatment.day > nextUncompletedDay,
                    onPressed: () => onDaySelected(treatment),
                  ),
                )
                .toList(),
          ),
        ],
      );
}

class _DayButton extends StatelessWidget {
  final int day;
  final bool isCurrent;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback onPressed;

  double get backgroundOpacity {
    if (App.isDayBreak) return isCurrent ? 0.95 : isLocked ? 0.12 : 0.3;
    return isCurrent ? 0.6 : isLocked ? 0.12 : 0.3;
  }

  double get iconOpacity {
    if (App.isDayBreak) return isCurrent || isCompleted ? 1 : 0.55;
    return isCurrent || isCompleted ? 0.55 : 0.1;
  }

  double getCircleSize(BuildContext context) =>
      (MediaQuery.of(context).size.width -
          2 * bigPadding -
          DaysMenu.spaceBetweenButtons * (DaysMenu.numberOfButtonsPerRow - 1)) /
      DaysMenu.numberOfButtonsPerRow;

  double getIconSize(BuildContext context) => 0.25 * getCircleSize(context);

  _DayButton({
    @required this.day,
    @required this.isCurrent,
    @required this.isCompleted,
    @required this.isLocked,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: isCurrent || isLocked ? null : onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: getCircleSize(context),
              height: getCircleSize(context),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(backgroundOpacity),
                shape: BoxShape.circle,
              ),
              child: Image(
                width: getIconSize(context),
                height: getIconSize(context),
                color: Colors.black.withOpacity(iconOpacity),
                image: AssetImage(
                  isCompleted && !isCurrent ? Assets.pillcastCheckMark : Assets.pillcastPlayButton,
                ),
              ),
            ),
            ColumnSeparator.small,
            TextScaled(
              "${localize(context, "start_card_days")} $day".toUpperCase(),
              style: AppTextStyles.h7ZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
            ),
          ],
        ),
      );
}
