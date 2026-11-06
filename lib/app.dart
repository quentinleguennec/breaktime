import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/landing/landing_page.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/scroll_behaviour_glowless.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class AppRoutes {
  static Map<String, WidgetBuilder> buildRoutes() {
    return {};
  }
}

class App extends StatelessWidget {
  static Locale locale;
  static const testerMode = false;
  static const httpLogsOn = false;
  static const httpCardsLogsOn = false;
  static const cacheLogsOn = false;
  static const userLogsOn = false;
  static const notificationLogsOn = false;
  static const showPerformanceOverlay = false;

  // Set to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  static const enableCrashlyticsInDevMode = false;
  static bool inDebugMode = false;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static String projectId;
  static bool isDayBreak = projectId == "daybreak-moodrise";
  static String appName = projectId == "daybreak-moodrise" ? "Daybreak" : "Moodrise";
  static String imageUrlPrefix = "https://storage.googleapis.com/$projectId.appspot.com/";

  @override
  Widget build(BuildContext context) =>
      // Uncomment to draw a grid on the whole screen.
//      GridPaper(
//        child:
      MaterialApp(
        showPerformanceOverlay: showPerformanceOverlay,
        debugShowCheckedModeBanner: false,
        title: appName,
        theme: appThemeData,
        routes: AppRoutes.buildRoutes(),
        builder: (context, child) => ScrollConfiguration(
          behavior: ScrollBehaviorGlowless(),
          child: child,
        ),
        home: Landing(),
        navigatorObservers: <NavigatorObserver>[
          FirebaseAnalyticsObserver(analytics: analytics),
          routeObserver,
        ],
        supportedLocales: [const Locale("en", "US")],
        localeResolutionCallback: localeResolutionCallback,
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
//        ),
      );

  Locale localeResolutionCallback(Locale locale, Iterable<Locale> supportedLocales) {
    if (supportedLocales == null) {
      App.locale = const Locale("en", "US");
      return App.locale;
    }
    supportedLocales.forEach((l) {
      if (l.languageCode == locale?.languageCode) {
        if (App.inDebugMode) print("Found match with $l for $locale");
        App.locale = l;
      }
    });
    if (App.locale == null) {
      App.locale = const Locale("en", "US");
    }
    return App.locale;
  }
}
