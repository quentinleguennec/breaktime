import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:aebeze/events/update_dashboard_event.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/services/watch_connectivity_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DashboardPagePresenter {
  final DashboardPagePresenterView _view;
  TrackingService _trackingService;
  UserService _userService;
  MemoryCache _cache;
  WatchConnectivityService _watchConnectivityService;
  EventBus _eventBus;
  bool isOpeningUserAccountPage = false;
  StreamSubscription _onUpdateDashboardSubscription;

  DashboardPagePresenter(this._view) {
    assert(_view != null);
    _cache = Injector().cache;
    _userService = Injector().userService;
    _trackingService = Injector().trackingService;
    _eventBus = Injector().eventBus;
    _watchConnectivityService = Injector().watchConnectivityService;
    if (Platform.isIOS) {
      _watchConnectivityService.activateWatchSession();
      _watchConnectivityService.sendColorAndMoodListToWatch();
      _watchConnectivityService.startListeningForData(saveMoodDataFromWatch);
    }
  }

  Map<String, List<Treatment>> get treatments => _cache.treatments;

  Map<String, int> get userLastOpenedTreatments => _cache.userLastOpenedTreatments;

  String get recommendedTreatmentType => _userService.getRecommendedTreatmentType();

  Map<String, Map<String, int>> get userCompletedTreatments => _cache.userCompletedTreatments;

  void openUserAccountPage() async {
    if (isOpeningUserAccountPage) {
      return;
    }
    isOpeningUserAccountPage = true;
    _view.pushUserAccountPage();
    isOpeningUserAccountPage = false;
  }

  Future<Null> openTreatment(
    Treatment treatment, {
    VoidCallback onTreatmentCompleted,
    bool isRecommendedTreatment,
  }) {
    _trackingService.onSelectedTreatment(treatment);
    _trackingService.startTreatment(treatment, isRecommendedTreatment);
    return _view.pushTreatment(
      treatment,
      onTreatmentCompleted: onTreatmentCompleted,
      isRecommendedTreatment: isRecommendedTreatment,
    );
  }

  void openMoodSelector() async {
    _trackingService.trackMood(source: "dashboard");
    await _view.pushMoodSelector(mood: _cache.lastCachedMood);
  }

  Treatment getTreatmentDayToShow(String treatmentType) {
    if (userLastOpenedTreatments == null || !userLastOpenedTreatments.containsKey(treatmentType)) {
      return treatments[treatmentType].first;
    }

    int lastOpenedDay = userLastOpenedTreatments[treatmentType];

    int highestCompletedDay =
        userCompletedTreatments[treatmentType]?.keys?.map((key) => int.tryParse(key) ?? 0)?.reduce(max) ?? 0;

    int treatmentIndexToOpen;
    if (highestCompletedDay < treatments[treatmentType].length) {
      // If there are still uncompleted treatments always open the next uncompleted one.
      // Note: We want to open the next day, and days index start at 1, so it's right to get the array element at day (and not day+1).
      treatmentIndexToOpen = highestCompletedDay;
    } else {
      // If all treatments have been completed open the one after the last opened.
      treatmentIndexToOpen = lastOpenedDay;
    }

    if (treatmentIndexToOpen >= treatments[treatmentType].length) {
      treatmentIndexToOpen = 0;
    }

    return treatments[treatmentType][treatmentIndexToOpen];
  }

  void subscribeEvents() {
    _onUpdateDashboardSubscription = _eventBus.on<UpdateDashboardEvent>().listen((event) => _view.updateDashboard());
  }

  void unsubscribeEvents() {
    _onUpdateDashboardSubscription?.cancel();
    if (Platform.isIOS) {
      _watchConnectivityService.stopListening();
    }
  }

  void saveMoodDataFromWatch(List results) async {
    for (Map<dynamic, dynamic> result in results) {
      result.forEach((date, _) {
        try {
          MoodData moodData = MoodData(
              mood: Moods().moods.first,
//          mood: Mood.fromName(result[date]),
              date: DateTime.fromMillisecondsSinceEpoch(1000 * double.parse(date).round()));
          // TODO: update for new mood tracker.
//          _userService.sendMoodTracking(moodData: moodData, deviceType: DeviceType.watch);
        } catch (e) {
          print(e);
          // Most likely to happen if list of moods in watch has not been updated to reflect those in the mobile app
        }
      });
    }
  }
}

abstract class DashboardPagePresenterView implements BasePresenterView {
  void updateDashboard();
}
