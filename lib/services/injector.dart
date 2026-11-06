import 'package:aebeze/firebase_cloud_messaging_service.dart';
import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/cache_loader.dart';
import 'package:aebeze/services/local_notification_service.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_repository.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/services/watch_connectivity_service.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

class Injector {
  static final Injector _singleton = Injector._internal();
  static MemoryCache _cache = MemoryCache();
  static EventBus _eventBus = EventBus();
  static CacheLoader _cacheLoader = CacheLoader();
  FirebaseCloudMessagingService _fcmService = FirebaseCloudMessagingService();
  static final GlobalKey<ScaffoldState> _rootBlocScaffoldKey = GlobalKey<ScaffoldState>();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  UserRepository get userRepository => UserRepository();

  Api get api => Api();

  UserService get userService => UserService(api, userRepository, cache, trackingService, localNotificationService);

  TrackingService get trackingService => TrackingService();

  LocalNotificationService get localNotificationService => LocalNotificationService();

  WatchConnectivityService get watchConnectivityService => WatchConnectivityService();

  MemoryCache get cache => _cache;

  CacheLoader get cacheLoader => _cacheLoader;

  EventBus get eventBus => _eventBus;

  FirebaseCloudMessagingService get fcmService => _fcmService;

  GlobalKey<ScaffoldState> get rootBlocScaffoldKey => _rootBlocScaffoldKey;
}
