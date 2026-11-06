import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseCloudMessagingService {
  final messaging = FirebaseMessaging();

  Future<String> setupAndGetToken() {
    messaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true));
    messaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    return messaging.getToken();
  }

  void configure({MessageHandler onMessage, MessageHandler onLaunch, MessageHandler onResume}) =>
      messaging.configure(onMessage: onMessage, onLaunch: onLaunch, onResume: onResume);

  void subscribeToTopic(String topic) => messaging.subscribeToTopic(topic);

  void unsubscribeFromTopic(String topic) => messaging.unsubscribeFromTopic(topic);
}
