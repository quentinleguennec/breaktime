import 'package:aebeze/authentication/authentication_presenter.dart';
import 'package:aebeze/mood_selector/mood_selector_list/mood_factor_selector_list_page.dart';
import 'package:aebeze/mood_selector/mood_selector_list/mood_selector_list_page.dart';
import 'package:aebeze/mood_tracker/widgets/emotions/emotions_insights_bloc.dart';
import 'package:aebeze/mood_tracker/widgets/factors/factors_insights_bloc.dart';
import 'package:aebeze/mood_tracker/widgets/mood_calendar/calendar_utils.dart';
import 'package:aebeze/mood_tracker/widgets/mood_calendar/mood_calendar.dart';
import 'package:aebeze/mood_tracker/widgets/weekly_checkins/weekly_checkins_insights_bloc.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:date_utils/date_utils.dart';

class InsightsPagePresenter {
  static const _startOfDayLastHour = 9;
  static const _middleOfDayLastHour = 17;
  static const _endOfDayLastHour = 24;

  final WeeklyCheckinsInsightsBloc weeklyCheckinsBloc = WeeklyCheckinsInsightsBloc();
  final EmotionsInsightsBloc emotionsBloc = EmotionsInsightsBloc();
  final FactorsInsightsBloc factorsBloc = FactorsInsightsBloc();
  final MoodTrackerPresenterView _view;

  TrackingService _trackingService;
  UserService _userService;
  List<MoodData> _moodData;
  List<CalendarMonthData> calendarMonthsData;

  InsightsPagePresenter(this._view) {
    _userService = Injector().userService;
    _trackingService = Injector().trackingService;
    assert(_view != null);
  }

  void loadAndProcessUserMoodData() async {
    List<MoodData> moodData = await _userService.fetchUserMoodData();
    moodData?.sort((m1, m2) => m2.date.compareTo(m1.date));
    this._moodData = List.unmodifiable(moodData);
    calendarMonthsData = _getMoodCalendarMonths();
    _view.onUserMoodDataLoaded();

    /// Wait a bit to give time to the (expensive) calendar Ui to generate before playing the animation.
    /// This prevents the animation to stutter.
    Future.delayed(const Duration(milliseconds: 1000), () => _updateInsightsData());
  }

  List<MoodData> getOrderedMoodDataForDay(DateTime day) {
    if (day == null || _moodData == null) {
      return null;
    }
    List<MoodData> dayMoodData = _moodData
        .where(
          (moodData) => Utils.isSameDay(moodData.date, day) && moodData.mood.isValid,
        )
        .toList();

    _orderMoodsByDateDesc(dayMoodData);
    return dayMoodData;
  }

  void trackDayDetailOpen() => _trackingService.moodCalendarDayDetailOpened();

  List<CalendarMonthData> _getMoodCalendarMonths() {
    List<CalendarMonthData> monthsData = List<CalendarMonthData>();
    DateTime firstMonth = Utils.firstDayOfMonth(DateTime.now());
    DateTime lastMonth =
        _moodData == null || _moodData.isEmpty ? firstMonth : Utils.firstDayOfMonth(_moodData.last.date);
    DateTime currentMonth = firstMonth;
    do {
      List<CalendarDayData> daysData =
          CalendarUtils.daysInMonth(currentMonth, startingDayOfWeek: CalendarMonth.startingDayOfWeek)
              .map((date) => CalendarDayData(
                    date,
                    _getStartOfDayAverageMoodValue(date),
                    _getMiddleOfDayAverageMoodValue(date),
                    _getEndOfDayAverageMoodValue(date),
                  ))
              .toList();

      monthsData.add(CalendarMonthData(currentMonth, daysData));
      currentMonth = Utils.previousMonth(currentMonth);
    } while (currentMonth.isAfter(lastMonth) || currentMonth.isAtSameMomentAs(lastMonth));

    return (monthsData);
  }

  void _updateInsightsData() {
    final DateTime thisDay = DateTime.now();
    final DateTime thisWeekFirstDay = Utils.firstDayOfWeek(thisDay);
    final DateTime thisDayLastWeek = Utils.previousWeek(thisDay);
    final DateTime lastWeekFirstDay = Utils.firstDayOfWeek(thisDayLastWeek);

    // weekday start on monday with 1 (ISO), we want sunday to be 1.
    int daysPerWeekCount = thisDay.weekday + 1;
    if (daysPerWeekCount == 8) {
      daysPerWeekCount = 1;
    }

    final List<MoodData> thisWeekData =
        List.unmodifiable(_moodData.where((data) => Utils.isSameWeek(thisDay, data.date)));
    final List<MoodData> lastWeekData = List.unmodifiable(
        _moodData.where((data) => data.date.isAfter(lastWeekFirstDay) && data.date.isBefore(thisDayLastWeek)).toList());

    void updateWeeklyChekinsInsightsData() {
      int thisWeekCheckinsCount = thisWeekData.length;
      int lastWeekCheckinsCount = lastWeekData.length;

      List<double> thisWeekValues = List.generate(
        daysPerWeekCount,
        (index) => thisWeekData
            .where(
              (data) => Utils.isSameDay(
                data.date,
                thisWeekFirstDay.add(Duration(days: index)),
              ),
            )
            .length
            .toDouble(),
      );

      List<double> lastWeekValues = List.generate(
        daysPerWeekCount,
        (index) => lastWeekData
            .where(
              (data) => Utils.isSameDay(
                data.date,
                lastWeekFirstDay.add(Duration(days: index)),
              ),
            )
            .length
            .toDouble(),
      );

      weeklyCheckinsBloc.startAnimation(
        newThisWeekCheckinsCount: thisWeekCheckinsCount,
        newLastWeekCheckinsCount: lastWeekCheckinsCount,
        newThisWeekValues: thisWeekValues,
        newLastWeekValues: lastWeekValues,
      );
    }

    void updateEmotionsInsightsData() {
      String feelingWithHighestDelta;
      int feelingWithHighestDeltaCountThisWeek;
      int feelingWithHighestDeltaCountLastWeek;
      int highestDelta = 0;

      MoodFeelingsSelectorList.feelings.forEach((feeling) {
        int countThisWeek = thisWeekData.where((data) => data.feelings.contains(feeling)).length;
        int countLastWeek = lastWeekData.where((data) => data.feelings.contains(feeling)).length;
        int delta = (countThisWeek - countLastWeek).abs();
        if (delta > highestDelta) {
          highestDelta = delta;
          feelingWithHighestDelta = feeling;
          feelingWithHighestDeltaCountThisWeek = countThisWeek;
          feelingWithHighestDeltaCountLastWeek = countLastWeek;
        }
      });

      emotionsBloc.startAnimation(
        newMainEmotion: feelingWithHighestDelta,
        newMainEmotionCountThisWeek: feelingWithHighestDeltaCountThisWeek,
        newMainEmotionCountLastWeek: feelingWithHighestDeltaCountLastWeek,
      );
    }

    void updateFactorsInsightsData() {
      const int topFactorsMaxCount = 3;
      List<Map<String, int>> topFactors = List.filled(topFactorsMaxCount, null, growable: true);

      List<String> allFactors = List<String>();
      MoodFactorSelectorList.factorsCategories.forEach((category) => allFactors.addAll(category.factors));

      allFactors.forEach((feeling) {
        int count = thisWeekData.where((data) => data.factors.contains(feeling)).length;
        for (int i = 0; i < topFactorsMaxCount; i++) {
          if (count > 0 && (topFactors[i] == null || count > topFactors[i].values.first)) {
            topFactors[i] = {feeling: count};
            break;
          }
        }
      });

      topFactors.removeWhere((factor) => factor == null);

      factorsBloc.startAnimation(
        newFactors: List.generate(
          topFactors.length,
          (index) => FactorData(
            factor: topFactors[index].keys.first,
            count: topFactors[index].values.first,
          ),
        ),
      );
    }

    updateWeeklyChekinsInsightsData();
    updateEmotionsInsightsData();
    updateFactorsInsightsData();
  }

  void _orderMoodsByDateDesc(List<MoodData> group) => group.sort((m1, m2) => m1.date.compareTo(m2.date));

  double _getStartOfDayAverageMoodValue(DateTime day) {
    List<MoodData> moods = _moodData
        .where((moodData) =>
            moodData.mood.isValid && Utils.isSameDay(moodData.date, day) && moodData.date.hour < _startOfDayLastHour)
        .toList();

    if (moods == null || moods.isEmpty) {
      return null;
    }

    int moodsValuesSum = moods.fold(0, (sum, mood) => sum + mood.mood.value);
    return moodsValuesSum / moods.length;
  }

  double _getMiddleOfDayAverageMoodValue(DateTime day) {
    List<MoodData> moods = _moodData
        .where((moodData) =>
            moodData.mood.isValid &&
            Utils.isSameDay(moodData.date, day) &&
            moodData.date.hour >= _startOfDayLastHour &&
            moodData.date.hour < _middleOfDayLastHour)
        .toList();

    if (moods == null || moods.isEmpty) {
      return null;
    }

    int moodsValuesSum = moods.fold(0, (sum, mood) => sum + mood.mood.value);
    return moodsValuesSum / moods.length;
  }

  double _getEndOfDayAverageMoodValue(DateTime day) {
    List<MoodData> moods = _moodData
        .where((moodData) =>
            moodData.mood.isValid &&
            Utils.isSameDay(moodData.date, day) &&
            moodData.date.hour >= _middleOfDayLastHour &&
            moodData.date.hour < _endOfDayLastHour)
        .toList();

    if (moods == null || moods.isEmpty) {
      return null;
    }

    int moodsValuesSum = moods.fold(0, (sum, mood) => sum + mood.mood.value);
    return moodsValuesSum / moods.length;
  }
}

abstract class MoodTrackerPresenterView implements BasePresenterView, AuthenticationPresenterView {
  void onUserMoodDataLoaded();
}
