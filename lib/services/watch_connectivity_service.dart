import 'dart:async';

import 'package:flutter/services.dart';

typedef OnWatchDataReceived(List result);

class WatchConnectivityService {
  StreamSubscription subscription;
  static const platform = const MethodChannel('com.aebeze.ios/info');
  static const stream = const EventChannel('com.aebeze.ios/info/data');

  void startListeningForData(OnWatchDataReceived callback) async {
    subscription = stream.receiveBroadcastStream().listen((value) {
      List result = value;
      if (result != null) {
        callback(result);
      }
    });
  }

  void stopListening() {
    subscription.cancel();
  }

  void activateWatchSession() async {
    await platform.invokeMethod("activateSession");
  }

  void sendColorAndMoodListToWatch() async {
    // TODO: update for new mood system
//    List<Mood> moods = MoodType.values.map((type) => Mood(type)).toList();
//    moods.removeWhere((mood) => mood.type == MoodType.unknown);
//
//    List<Map> colourAndMoodList = moods
//        .map((mood) => {
//              mood.name: {
//                "R": mood.color.red.toString(),
//                "G": mood.color.green.toString(),
//                "B": mood.color.blue.toString()
//              }
//            })
//        .toList();
//
//    Map colourAndMoodDict = {"Colours": colourAndMoodList};
//
//    await platform.invokeMethod("receiveMoodsFromMobileApp", {"colourAndMoodDict": colourAndMoodDict});
  }
}
