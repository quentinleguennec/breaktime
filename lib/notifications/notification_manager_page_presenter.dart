import 'dart:async';
import 'dart:convert';

import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/local_notification_service.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class NotificationManagerPagePresenter {
  final NotificationManagerPagePresenterView _view;

  LocalNotificationService _localNotificationService;
  TrackingService _trackingService;

  bool _areNotificationsOn = true;

  bool get areNotificationsOn => _areNotificationsOn;

  NotificationManagerPagePresenter(this._view) {
    assert(_view != null);
    _trackingService = Injector().trackingService;
    _localNotificationService = Injector().localNotificationService;
  }

  Future<void> loadUserNotificationPref() async {
    _areNotificationsOn = await _localNotificationService.loadUserNotificationPref();
  }

  Future<void> onNotificationPrefChanged(bool isSwitchedOn) async {
    _areNotificationsOn = isSwitchedOn;
    _trackingService.notificationPrefChanged(isSwitchedOn);
    await _localNotificationService.updateUserNotificationPref(isSwitchedOn);
  }

  Future<void> scheduleTestNotification() => _localNotificationService
      .scheduleNotificationAfterDuration(
        id: 0,
        title: "test title",
        body: "test body",
        payload: json.encode({'screen': 'mood_selector'}),
        duration: Duration(seconds: 5),
      )
      .catchError((e) => print("Error $e"));
}

abstract class NotificationManagerPagePresenterView implements BasePresenterView {}
