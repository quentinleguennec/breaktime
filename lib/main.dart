import 'dart:async';

import 'package:aebeze/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() async {
  assert(() {
    final debugView = false;
    debugPaintSizeEnabled = debugView;
    debugPaintBaselinesEnabled = false; //cause crash
    debugPaintLayerBordersEnabled = debugView;
    debugPaintPointersEnabled = debugView;
    debugRepaintRainbowEnabled = debugView;
    App.inDebugMode = true;
    return true;
  }());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  Firestore firestore = Firestore.instance;
  firestore.settings(timestampsInSnapshotsEnabled: true);
  var options = await Firestore.instance.app.options;
  App.projectId = options.projectID;

  Crashlytics.instance.enableInDevMode = App.enableCrashlyticsInDevMode;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZonedGuarded<Future<Null>>(
    () async => runApp(App()),
    Crashlytics.instance.recordError,
  );
}
