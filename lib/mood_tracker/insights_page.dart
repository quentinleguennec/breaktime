import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/bloc_pattern/bloc_provider.dart';
import 'package:aebeze/mood_tracker/insights_page_presenter.dart';
import 'package:aebeze/mood_tracker/widgets/commons/page_background.dart';
import 'package:aebeze/mood_tracker/widgets/emotions/emotions_insights.dart';
import 'package:aebeze/mood_tracker/widgets/emotions/emotions_insights_bloc.dart';
import 'package:aebeze/mood_tracker/widgets/factors/factors_insights.dart';
import 'package:aebeze/mood_tracker/widgets/factors/factors_insights_bloc.dart';
import 'package:aebeze/mood_tracker/widgets/mood_calendar/mood_calendar.dart';
import 'package:aebeze/mood_tracker/widgets/mood_day_detail.dart';
import 'package:aebeze/mood_tracker/widgets/weekly_checkins/weekly_checkins_insights.dart';
import 'package:aebeze/mood_tracker/widgets/weekly_checkins/weekly_checkins_insights_bloc.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class InsightsPage extends PopupRoute<Null> {
  static const double daysRowsHorizontalPadding = 10;

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => true;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
          BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(
        child: child,
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _PageLayout();
}

class _PageLayout extends StatefulWidget {
  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements MoodTrackerPresenterView {
  static const EdgeInsets _insightWidgetsMargin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets _insightWidgetsPadding = const EdgeInsets.all(24);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MoodDayDetailController moodDayDetailController = MoodDayDetailController();

  InsightsPagePresenter presenter;

  _PageLayoutState() {
    presenter = InsightsPagePresenter(this);
  }

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  @override
  void initState() {
    presenter.loadAndProcessUserMoodData();
    super.initState();
  }

  @override
  void onUserMoodDataLoaded() => refreshState();

  void closePage() {
    if (moodDayDetailController.isVisible) {
      moodDayDetailController.hide();
    } else {
      pop();
    }
  }

  void onDaySelected(DateTime date) {
    List<MoodData> orderedMoodData = presenter.getOrderedMoodDataForDay(date);
    if (orderedMoodData != null && orderedMoodData.isNotEmpty) {
      presenter.trackDayDetailOpen();
      moodDayDetailController.showDay(orderedMoodData);
    }
  }

  Widget get title => TextScaled(
        localize(context, "insights_page_title"),
        style: App.isDayBreak ? AppTextStyles.bigTitle : AppTextStyles.bigTitle.copyWith(color: Color(0xF2FFFFFF)),
      );

  Widget get backgroundColor => Stack(
        children: <Widget>[
          if (!App.isDayBreak) ...[
            Image.asset(
              Assets.backgroundInsightsMoodrise,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
            Container(color: Colors.white.withOpacity(0.1)),
          ],
          if (App.isDayBreak)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.backgroundGradientColors,
                ),
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          closePage();
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.backgroundGradientColors.last,
          body: Stack(
            children: <Widget>[
              InsightsPageBackground(),
              SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: NavigationAppBarOverlay(
                            withInvertedColor: !App.isDayBreak,
                          ),
                        ),
                        ColumnSeparator.veryBig,
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: title,
                        ),
                        ColumnSeparator.big,
                        BlocProvider<WeeklyCheckinsInsightsBloc>(
                          bloc: presenter.weeklyCheckinsBloc,
                          child: WeeklyCheckinsInsights(
                            margin: _insightWidgetsMargin,
                            padding: _insightWidgetsPadding,
                          ),
                        ),
                        BlocProvider<EmotionsInsightsBloc>(
                          bloc: presenter.emotionsBloc,
                          child: EmotionsInsight(
                            margin: _insightWidgetsMargin,
                            padding: _insightWidgetsPadding,
                          ),
                        ),
                        BlocProvider<FactorsInsightsBloc>(
                          bloc: presenter.factorsBloc,
                          child: FactorsInsight(
                            margin: _insightWidgetsMargin,
                            padding: _insightWidgetsPadding,
                          ),
                        ),
                      ],
                    ),
                    ColumnSeparator.big,
                    AnimatedOpacity(
                      opacity: isEmptyOrNull(presenter.calendarMonthsData) ? 0 : 1,
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < (presenter.calendarMonthsData?.length ?? 0); i++)
                            CalendarMonth(
                              monthData: presenter.calendarMonthsData[i],
                              onDaySelected: onDaySelected,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              MoodDayDetail(controller: moodDayDetailController),
            ],
          ),
        ),
      );
}
