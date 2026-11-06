import 'dart:async';
import 'dart:convert';

import 'package:aebeze/app.dart';
import 'package:aebeze/firebase_cloud_messaging_service.dart';
import 'package:aebeze/services/cache_loader.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/local_notification_service.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class RootState {
  final bool showLoading;
  final bool showOnboarding;
  final bool showDashboard;
  final bool showAuthentication;
  final bool skipEmailVerification;
  final User user;
  final Mood mood;

  RootState({
    this.showLoading = false,
    this.showOnboarding = false,
    this.showDashboard = false,
    this.showAuthentication = false,
    this.skipEmailVerification = false,
    this.user,
    this.mood,
  });

  RootState copyWith({
    bool showLoading,
    bool showOnboarding,
    bool showDashboard,
    bool showAuthentication,
    bool skipEmailVerification,
    User user,
    Mood mood,
  }) =>
      RootState(
        showLoading: showLoading ?? this.showLoading,
        showOnboarding: showOnboarding ?? this.showOnboarding,
        showDashboard: showDashboard ?? this.showDashboard,
        showAuthentication: showAuthentication ?? this.showAuthentication,
        skipEmailVerification: skipEmailVerification ?? this.skipEmailVerification,
        user: user ?? this.user,
        mood: mood ?? this.mood,
      );

  bool get userNeedsVerification => user != null && !user.isAnonymous && !user.isVerified;
}

class RootBloc {
  UserService _userService = Injector().userService;
  CacheLoader _cacheLoader = Injector().cacheLoader;
  TrackingService _trackingService = Injector().trackingService;
  LocalNotificationService _localNotificationService = Injector().localNotificationService;
  FirebaseCloudMessagingService _fcmService = Injector().fcmService;

  final PublishSubject<RootState> _rootState = PublishSubject<RootState>();

  Observable<RootState> get rootStateObservable => _rootState.stream;

  final PublishSubject<NotificationPayload> _notificationState = PublishSubject<NotificationPayload>();

  Observable<NotificationPayload> get notificationStateObservable => _notificationState.stream;

  final PublishSubject<bool> _loadingAnimationSubject = PublishSubject<bool>();
  final PublishSubject<bool> _loadingDataSubject = PublishSubject<bool>();
  Observable<bool> _loadingSubject;
  Mood mood;

  RootBloc();

  void load() async {
    bool showOnboarding = await _userService.needOnboarding();
    User user = await _userService.getUser();

    RootState rootState = RootState(
      showLoading: true,
      showOnboarding: showOnboarding,
      showAuthentication: user.isAnonymous,
      user: user,
    );
    if (_loadingAnimationSubject.isClosed) {
      _loadingSubject = _loadingDataSubject;
    } else {
      _loadingSubject = _loadingDataSubject.zipWith(
        _loadingAnimationSubject,
        (a, b) {
          if (App.inDebugMode) print("_loadingSubject: zipped");
          return a && b;
        },
      );
    }
    _loadingSubject.listen(
      (noError) {
        if (App.inDebugMode) print("Loading and animation finished. With error = ${!noError}");
        _updateState(
          RootState(
            showOnboarding: showOnboarding,
            showDashboard: true,
            showAuthentication: user.isAnonymous,
            user: user,
            mood: mood,
          ),
        );
        if (!showOnboarding && !(App.isDayBreak && user.isAnonymous)) {
          _setupNotificationServices();
        }
      },
    );
    _updateState(rootState);
    _cacheLoader.prepare(
      () {
        if (App.inDebugMode) print("_loadingDataSubject end");
        _loadingDataSubject.add(true);
      },
      futuresToExecuteInParallel: [
        _loadLastMood(),
      ],
      onError: (e) {
        if (App.inDebugMode) print("_loadingDataSubject end : error");
        _loadingDataSubject.add(false);
      },
    );
  }

  Future<void> _loadLastMood() async {
    this.mood = await _userService.fetchLastMood();
    if (App.cacheLogsOn) print("- mood data loaded");
  }

  void onboardingEnd(RootState state) async {
    if (!state.showAuthentication) {
      _setupNotificationServices();
    }
    _updateState(
      state.copyWith(
        showOnboarding: false,
        showDashboard: true,
      ),
    );
  }

  void onAuthenticationComplete(RootState state) async {
    _setupNotificationServices();
    _updateState(
      state.copyWith(
        showAuthentication: false,
        skipEmailVerification: true,
        user: await _userService.getUser(),
      ),
    );
  }

  void onLoadingAnimationCompleted() async {
    if (App.inDebugMode) print("onLoadingAnimationCompleted");
    _loadingAnimationSubject.add(true);
    _loadingAnimationSubject.close();
  }

  Future<void> refreshRandomNotifications() async {
    if (_localNotificationService.isInitialized) {
      await _localNotificationService.setupRandomNotifications();
    }
  }

  Future _setupNotificationServices() async {
    await _setupFcmAndSaveToken();
    await _addFcmCallback();
    await _setupLocalNotification();
  }

  Future<bool> _setupLocalNotification() async {
    bool success = await _localNotificationService.setup((payload) {
      if (App.notificationLogsOn) print("Notifications - received notification with payload: $payload");
      if (payload != null) {
        NotificationPayload notificationPayload = NotificationPayload.fromJson(json.decode(payload));
        if (App.notificationLogsOn) print("Notifications - payload parsed $notificationPayload");
        _trackingService.localNotificationOpened();
        if (App.notificationLogsOn) print("Notifications - Adding notification to sink $notificationPayload");
        _notificationState.sink.add(notificationPayload);
      } else {
        if (App.notificationLogsOn) print("Notifications - payload is null");
        // TODO why we handle the case with payload == null
        //   } else {
        //     /// Only for backend push notifications and only on iOS.
        //     // TODO: add a flag in the notification to says if it comes from the backend or is local.
        //     //on iOS th fcm callback doesn't work so we need to handle clicks on notification in here, btw this isn't called when the app is in foreground
        //     Navigator.popUntil(context, (currentRoute) => (currentRoute.settings == TrackingService.dashboardPage));
        //   }
      }
      return null;
    });

    if (success) {
      await _localNotificationService.setupRandomNotifications();
      if (App.inDebugMode) await _localNotificationService.printPendingNotificationRequests();
      await _localNotificationService.cancelAllNonRandomNotifications();
    }

    return success;
  }

  Future<void> _setupFcmAndSaveToken() async {
    final token = await _fcmService.setupAndGetToken();
    await _userService.addFcmToken(token);
    if (App.notificationLogsOn) print("Notifications - setupFcmAndSaveToken done");
  }

  Future<void> _addFcmCallback() {
    return Future.delayed(Duration(seconds: 0), () {
      _fcmService.configure(
        onResume: (payload) async => _notificationState.sink.add(NotificationPayload.fromJson(payload)),
        onLaunch: (payload) async => _notificationState.sink.add(NotificationPayload.fromJson(payload)),
      );
      if (App.notificationLogsOn) print("Notifications - addFcmCallback done");
    });
  }

  void dispose() {
    _rootState.close();
    _loadingDataSubject.close();
    _loadingAnimationSubject.close();
    _notificationState.close();
  }

  void _updateState(RootState rootState) => _rootState.sink.add(rootState);
}
