import 'dart:convert';
import 'dart:math';

import 'package:aebeze/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  static const int _randomNotificationEarliestHourOfDay = 8;
  static const int _randomNotificationLatestHourOfDay = 18;
  static const String _lastScheduleDayPrefKey = 'lastRandomNotificationScheduleDay';
  static const String _userNotificationPrefKey = 'userNotificationPrefKey';
  // TODO: Isn't this missing a dot for daybreak?
  static final String _groupChannelId = 'com.aebeze' + (App.isDayBreak ? "daybreak" : "");
  static const String _groupChannelName = 'Notifications';
  static const String _groupChannelDescription = 'Notifications';
  static const String _icon = 'notification_icon'; // icon stored in the android resources
  static const String _randomNotificationType = 'random';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitializing = false;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  String get randomNotificationPayload => json.encode({'screen': 'mood_selector', "type": _randomNotificationType});

  Future<bool> setup(SelectNotificationCallback onSelectNotification) async {
    if (!isInitialized && !_isInitializing) {
      _isInitializing = true;
      var initializationSettingsAndroid = AndroidInitializationSettings(_icon);
      var initializationSettingsIOS =
          IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
      _isInitialized = await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);
      _isInitializing = false;
    }
    return isInitialized;
  }

  Future showNotification({int id, String title, String body, String payload}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        _groupChannelId, _groupChannelName, _groupChannelDescription,
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  Future scheduleNotificationAfterDuration(
          {int id, String title, String body, String payload, Duration duration}) async =>
      scheduleNotification(id: id, title: title, body: body, payload: payload, date: DateTime.now().add(duration));

  /// Id must be unique for each notification, else it will just overwrite the notification with same id.
  Future scheduleNotification({
    @required int id,
    @required String title,
    @required String body,
    @required String payload,
    @required DateTime date,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(_groupChannelId, _groupChannelName, _groupChannelDescription, icon: _icon);
    final IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      date,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future setupRandomNotifications() async {
    final bool areNotificationsOn = await loadUserNotificationPref();
    if (!areNotificationsOn) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 5, 0);

    DateTime lastRandomNotificationScheduleDay = DateTime.parse(
      prefs.getString(_lastScheduleDayPrefKey) ?? today.toIso8601String(),
    );

    DateTime oneWeekFromToday = today.add(Duration(days: 7));
    if (oneWeekFromToday.isBefore(lastRandomNotificationScheduleDay)) {
      // This should not happen. Reset notifications.
      lastRandomNotificationScheduleDay = today;
      await cancelAllNotifications();
    }

    DateTime newNotificationsStartingDay =
        lastRandomNotificationScheduleDay.isBefore(today) ? today : lastRandomNotificationScheduleDay;

    lastRandomNotificationScheduleDay =
        await _scheduleTwoRandomNotificationsEachDayInRange(newNotificationsStartingDay, oneWeekFromToday);
//    lastRandomNotificationScheduleDay = await _scheduleManyRandomNotificationsEachDayInRange(newNotificationsStartingDay,  today.add(Duration(days: 3)));
//    lastRandomNotificationScheduleDay = await _scheduleRandomNotificationsEveryFiveMinutesForNextHour();
    await prefs.setString(_lastScheduleDayPrefKey, lastRandomNotificationScheduleDay.toIso8601String());
  }

  /// From [start], exclusive, to [end], inclusive.
  Future<DateTime> _scheduleTwoRandomNotificationsEachDayInRange(DateTime start, DateTime end) async {
    DateTime day = DateTime(start.year, start.month, start.day, 5, 0);
    final int daysCountInRange = DateTime(end.year, end.month, end.day, 10, 0).difference(day).inDays;
    for (int i = 0; i < daysCountInRange; i++) {
      day = day.add(Duration(days: 1));
      await _scheduleTwoRandomNotificationsForDay(day);
    }
    return day;
  }

  Future _scheduleTwoRandomNotificationsForDay(final DateTime day) async {
    final int validTimeOfDayRangeLength = _randomNotificationLatestHourOfDay - _randomNotificationEarliestHourOfDay;

    final int randomHourOfDay1 = getRandomInRange(
      _randomNotificationEarliestHourOfDay,
      _randomNotificationEarliestHourOfDay + validTimeOfDayRangeLength ~/ 2,
    );
    final int randomHourOfDay2 = getRandomInRange(
      _randomNotificationEarliestHourOfDay + validTimeOfDayRangeLength ~/ 2,
      _randomNotificationLatestHourOfDay,
    );

    final DateTime randomDate1 = DateTime(day.year, day.month, day.day, randomHourOfDay1, 0);
    final DateTime randomDate2 = DateTime(day.year, day.month, day.day, randomHourOfDay2, 0);

    NotificationText textPair1 = NotificationText.getRandom();
    NotificationText textPair2 = NotificationText.getRandom();

    await scheduleNotification(
      id: randomDate1.toIso8601String().hashCode,
      title: textPair1.title,
      body: textPair1.body,
      payload: randomNotificationPayload,
      date: randomDate1,
    );
    if (App.inDebugMode) print("Added notification on day $randomDate1");
    await scheduleNotification(
      id: randomDate2.toIso8601String().hashCode,
      title: textPair2.title,
      body: textPair2.body,
      payload: randomNotificationPayload,
      date: randomDate2,
    );
    if (App.inDebugMode) print("Added notification on day $randomDate2");
  }

  /// Schedule notifications for each hour in the allowed hours range, each day.
  /// For testing only.
  /// From [start], inclusive, to [end], inclusive.
  // ignore: unused_element
  Future<DateTime> _scheduleManyRandomNotificationsEachDayInRange(DateTime start, DateTime end) async {
    DateTime day = DateTime(start.year, start.month, start.day, 5, 0);
    final int daysCountInRange = DateTime(end.year, end.month, end.day, 10, 0).difference(day).inDays;
    for (int i = 0; i < daysCountInRange; i++) {
      await _scheduleManyRandomNotificationsForDay(day);
      day = day.add(Duration(days: 1));
    }
    return day;
  }

  /// Schedule notifications for each hour in the allowed hours range.
  /// For testing only.
  Future _scheduleManyRandomNotificationsForDay(final DateTime day) async {
    for (int i = _randomNotificationEarliestHourOfDay; i < _randomNotificationLatestHourOfDay; i++) {
      final DateTime date = DateTime(day.year, day.month, day.day, i, 0);
      NotificationText textPair = NotificationText.getRandom();
      await scheduleNotification(
        id: date.toIso8601String().hashCode,
        title: textPair.title,
        body: textPair.body,
        payload: randomNotificationPayload,
        date: date,
      );
      print("Notification scheduled for ${date.toIso8601String()}");
    }
  }

  /// Schedule notifications every five minutes for 1 hour.
  /// For testing only.
  // ignore: unused_element
  Future _scheduleRandomNotificationsEveryFiveMinutesForNextHour() async {
    DateTime date = DateTime.now();
    for (int i = 0; i < 12; i++) {
      date = date.add(Duration(minutes: 5));
      NotificationText textPair = NotificationText.getRandom();
      await scheduleNotification(
        id: date.toIso8601String().hashCode,
        title: textPair.title,
        body: textPair.body,
        payload: randomNotificationPayload,
        date: date,
      );
      print("Notification scheduled for ${date.toIso8601String()}");
    }
    return date;
  }

  /// From [start], inclusive, to [end], exclusive.
  int getRandomInRange(int start, int end) => start + Random().nextInt(end - start);

  Future scheduleDailyNotification(int id, String title, String body, String payload, Time notificationTime) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(_groupChannelId, _groupChannelName, _groupChannelDescription);
    final IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      id,
      title,
      body,
      notificationTime,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<List<PendingNotificationRequest>> _getPendingNotifications() =>
      flutterLocalNotificationsPlugin.pendingNotificationRequests();

  Future<void> printPendingNotificationRequests() async {
    print("------------- START Pending Notifications -------------");
    int i = 1;
    for (PendingNotificationRequest n in await _getPendingNotifications()) {
      print('$i: {id: ${n.id}, title: ${n.title}, body: ${n.body}, payload: ${n.payload}');
      i++;
    }
    print("------------- END Pending Notifications -------------");
  }

  Future<void> cancelNotification(int id) => flutterLocalNotificationsPlugin.cancel(id);

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastScheduleDayPrefKey, null);
  }

  Future<void> resetNotifications() async {
    await cancelAllNotifications();
    await setupRandomNotifications();
  }

  /// This is to clear the old daily notifications for users that joined before we switched to the
  /// random notifications system.
  Future cancelAllNonRandomNotifications() async {
    for (PendingNotificationRequest notification in await _getPendingNotifications()) {
      Map<String, dynamic> payload = jsonDecode(notification.payload);
      if (payload["type"] != _randomNotificationType) {
        if (App.inDebugMode) print("Canceling notifcation: ${notification.title}, ${notification.body}");
        await cancelNotification(notification.id);
      }
    }
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    /// Callback for handling when a notification is triggered while the app is in the foreground. Applicable to iOS versions < 10 only
  }

  Future<bool> loadUserNotificationPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userNotificationPrefKey) ?? true;
  }

  Future<void> updateUserNotificationPref(bool isOn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userNotificationPrefKey, isOn);
    if (isOn) {
      await setupRandomNotifications();
    } else {
      await cancelAllNotifications();
    }
  }
}

@immutable
class NotificationText {
  final String title;
  final String body;

  NotificationText(this.title, this.body);

  static NotificationText getRandom() {
    int randomIndex = Random().nextInt(_notificationTextPairs.length);
    return NotificationText(_notificationTextPairs[randomIndex]['title'], _notificationTextPairs[randomIndex]['body']);
  }

  static final List<Map> _notificationTextPairs = [
    {
      "title": "Gentle reminder:",
      "body": "Take a moment to track your mood.",
    },
    {
      "title": "Feelings matter.",
      "body": "Let's track how you feel, with a simple tap.",
    },
    {
      "title": "Time to check-in",
      "body": "Tap here, to track how you're feeling right now.",
    },
    {
      "title": "Time to check-in",
      "body": "Take a moment to track how you're feeling.",
    },
    {
      "title": "Gentle reminder-",
      "body": "Tap here to track to track your mood.",
    },
    {
      "title": "How are you feeling?",
      "body": "Take a second to track your mood.",
    },
    {
      "title": "Your mood matters.",
      "body": "Tap here to track how you're feeling, right now.",
    },
    {
      "title": "Quick reminder-",
      "body": "Take a second to capture how you're feeling.",
    },
  ];
}
