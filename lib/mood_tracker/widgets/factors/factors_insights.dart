import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/bloc_pattern/bloc_provider.dart';
import 'package:aebeze/mood_tracker/widgets/commons/count_bar.dart';
import 'package:aebeze/mood_tracker/widgets/commons/count_text.dart';
import 'package:aebeze/mood_tracker/widgets/factors/factors_insights_bloc.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FactorsInsight extends StatelessWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;

  const FactorsInsight({@required this.margin, @required this.padding});

  String getMainFactorsText(BuildContext context, List<FactorData> factorsData) {
    String text = localize(context, "factors_header");

    if (factorsData == null) {
      return text;
    }

    List<FactorData> nonEmptyfactorsData = List.from(factorsData);
    nonEmptyfactorsData.removeWhere((factorsData) => factorsData.factor == null || factorsData.factor == "");

    if (nonEmptyfactorsData.isEmpty) {
      return text;
    }

    if (nonEmptyfactorsData.length == 1) {
      return "$text ${nonEmptyfactorsData.first.factor}.";
    }

    text =
        "$text ${nonEmptyfactorsData.sublist(1, nonEmptyfactorsData.length - 1).fold(nonEmptyfactorsData.first.factor, (previousValue, factorData) => "$previousValue, ${factorData.factor}")}";
    text = "$text and ${nonEmptyfactorsData.last.factor}.";

    return text;
  }

  Widget getHeader(BuildContext context, List<FactorData> factorsData) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          TextScaled(
            localize(context, "factors"),
            style: AppTextStyles.h5ZirkonRegular.copyWith(color: Colors.white),
          ),
          ColumnSeparator.small,
          TextScaled(
            getMainFactorsText(context, factorsData),
            style: AppTextStyles.bodyZirkonRegular.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      );

  List<Widget> getBarsAndCounts(BuildContext context, List<FactorData> factorsData) => factorsData
      .map(
        (factorData) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ColumnSeparator.medium,
            CountText(
              text: localize(context, "factors_checkins_mentioned"),
              count: factorData.count ?? 0,
            ),
            ColumnSeparator.tiny,
            CountBar(
              fillRatio: factorData.barFillRatio ?? 0.5,
              text: factorData.factor,
              color: identical(factorData, factorsData.first)
                  ? App.isDayBreak ? AppColors.accentColor : Colors.white
                  : App.isDayBreak ? AppColors.insightsWidgetGrey : Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) => StreamBuilder<FactorsInsightsState>(
        stream: BlocProvider.of<FactorsInsightsBloc>(context).stream,
        builder: (context, AsyncSnapshot<FactorsInsightsState> snapshot) => AnimatedOpacity(
          opacity: snapshot.data?.isEmpty == false ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: snapshot.data?.factors == null || snapshot.data.isEmpty
              ? Container()
              : Container(
                  margin: margin,
                  padding: padding,
                  decoration: AppDecorations.transparentBox,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getHeader(context, snapshot.data?.factors),
                      ColumnSeparator.medium,
                      const SeparatorLine(),
                      ...getBarsAndCounts(context, snapshot.data?.factors),
                    ],
                  ),
                ),
        ),
      );
}
