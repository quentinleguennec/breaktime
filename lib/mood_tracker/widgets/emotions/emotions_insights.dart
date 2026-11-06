import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/bloc_pattern/bloc_provider.dart';
import 'package:aebeze/mood_tracker/widgets/commons/count_bar.dart';
import 'package:aebeze/mood_tracker/widgets/commons/count_text.dart';
import 'package:aebeze/mood_tracker/widgets/emotions/emotions_insights_bloc.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmotionsInsight extends StatelessWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;

  const EmotionsInsight({@required this.margin, @required this.padding});

  Widget getHeader(BuildContext context, String emotion, int countThisWeek, int countLastWeek) {
    String bodyText = localize(context, "emotions_header");
    if (countThisWeek > countLastWeek) {
      bodyText = "$bodyText ${localize(context, "insights_more")}";
    } else {
      bodyText = "$bodyText ${localize(context, "insights_less")}";
    }
    bodyText = "$bodyText $emotion.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextScaled(
          localize(context, "emotions"),
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
  Widget build(BuildContext context) => StreamBuilder<EmotionsInsightsState>(
        stream: BlocProvider.of<EmotionsInsightsBloc>(context).stream,
        builder: (context, AsyncSnapshot<EmotionsInsightsState> snapshot) => AnimatedOpacity(
          opacity: snapshot.data?.isEmpty == false ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: snapshot.data == null || snapshot.data.isEmpty
              ? Container()
              : Container(
                  margin: margin,
                  padding: padding,
                  decoration: AppDecorations.transparentBox,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getHeader(
                          context,
                          snapshot.data?.mainEmotion ?? "",
                          snapshot.data?.mainEmotionCountThisWeek?.floor() ?? 0,
                          snapshot.data?.mainEmotionCountLastWeek?.floor() ?? 0),
                      ColumnSeparator.medium,
                      const SeparatorLine(),
                      ColumnSeparator.medium,
                      CountText(
                        text: "${localize(context, "emotions_times_you_felt")} ${snapshot.data?.mainEmotion ?? ""}",
                        count: snapshot.data?.mainEmotionCountThisWeek?.floor() ?? 0,
                      ),
                      ColumnSeparator.tiny,
                      CountBar(
                        fillRatio: snapshot.data?.thisWeekBarFillRatio ?? 0.5,
                        text: localize(context, "emotions_this_week"),
                        color: App.isDayBreak ? AppColors.accentColor : Colors.white,
                      ),
                      ColumnSeparator.medium,
                      CountText(
                        text: "${localize(context, "emotions_times_you_felt")} ${snapshot.data?.mainEmotion ?? ""}",
                        count: snapshot.data?.mainEmotionCountLastWeek?.floor() ?? 0,
                      ),
                      ColumnSeparator.tiny,
                      CountBar(
                        fillRatio: snapshot.data?.lastWeekBarFillRatio ?? 0.5,
                        text: localize(context, "emotions_last_week"),
                        color: App.isDayBreak ? AppColors.insightsWidgetGrey : Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
        ),
      );
}
