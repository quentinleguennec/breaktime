import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class DashboardTopBar extends StatelessWidget {
  Widget getTitle(BuildContext context) => TextScaled(
        App.appName,
        style: AppTextStyles.dashboardHeaderTitle,
      );

  Widget getDate(BuildContext context) => TextScaled(
        DateFormat("MMMM d, y").format(DateTime.now()),
        style: AppTextStyles.captionZirkonRegular.copyWith(color: AppColors.baseColorFaded),
      );

  Widget get bar => Container(
        width: 16,
        height: 1,
        color: AppColors.baseColorFaded,
      );

  Widget getBars() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(alignment: Alignment.centerLeft, child: bar),
          Align(alignment: Alignment.centerRight, child: bar),
        ],
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: bigPadding),
        child: Column(
          children: <Widget>[
            ColumnSeparator.veryHuge,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                getTitle(context),
                getDate(context),
              ],
            ),
            ColumnSeparator.medium,
            getBars(),
          ],
        ),
      );
}
