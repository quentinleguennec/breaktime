import 'package:aebeze/app.dart';
import 'package:aebeze/services/model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TrackingService {
  static const loginPage = const RouteSettings(name: "login_page");
  static const resetPasswordPage = const RouteSettings(name: "reset_password_page");
  static const signUpPage = const RouteSettings(name: "sign_up_page");
  static const authenticationPage = const RouteSettings(name: "authentication_page");
  static const accountPage = const RouteSettings(name: "account_page");
  static const aboutPage = const RouteSettings(name: "about_page");
  static const termsPage = const RouteSettings(name: "terms_page");
  static const sharePage = const RouteSettings(name: "share_page");
  static const phq9PopupPage = const RouteSettings(name: "phq9_popup_page");
  static const phq9Page = const RouteSettings(name: "phq9_page");
  static const phq9DaybreakPage = const RouteSettings(name: "phq9_daybreak_page");
  static const supportingSciencesPage = const RouteSettings(name: "supporting_sciences");
  static const testerPage = const RouteSettings(name: "tester_page");
  static const dashboardPage = const RouteSettings(name: "dashboard_page");
  static const rootPage = const RouteSettings(name: "root_page");
  static const treatmentPage = const RouteSettings(name: "treatment_page");
  static const deepLinkPage = const RouteSettings(name: "deep_link_page");
  static const notificationManagerPage = const RouteSettings(name: "notification_manager_page");

  final analytics = FirebaseAnalytics();

  void updateUser(User user) => analytics.setUserId(user.uid);

  void login() => analytics.logLogin();

  void facebookLogin() => analytics.logEvent(name: 'login', parameters: {"type": "facebook"});

  void signUp() => analytics.logSignUp(signUpMethod: "custom");

  void viewCard(DataCard card) => analytics.logViewItem(
        itemId: card.uid,
        itemName: "card",
        itemCategory: card.type,
      );

  void onSelectedTreatment(Treatment treatment) => analytics.logViewItem(
        itemId: treatment.uid,
        itemName: "treatment",
        itemCategory: treatment.type,
      );

  void startTreatment(Treatment treatment, bool isRecommendedTreatment) =>
      analytics.logEvent(name: "treatment_start", parameters: {
        "itemId": treatment.uid,
        "itemName": "treatment",
        "itemCategory": treatment.type,
        "isRecommendedTreatment": isRecommendedTreatment
      });

  void saveCard(DataCard card) => analytics.logEvent(name: "save_card", parameters: {
        "itemId": card.uid,
        "itemName": card.title,
        "itemCategory": card.type,
      });

  void cardCompleted(DataCard card) => analytics.logEvent(name: "card_completed", parameters: {
        "itemId": card.uid,
        "itemName": card.title,
        "itemCategory": card.type,
        "duration": card.duration?.inSeconds
      });

  void share(String shareType, String cardUid) =>
      analytics.logShare(contentType: "card-$shareType", itemId: cardUid, method: shareType);

  void upsellButtonPressed(String cardUid) => analytics.logEvent(
        name: "upsell_button_pressed",
        parameters: {
          "itemId": cardUid,
        },
      );

  void trackMood({String source}) => analytics.logEvent(name: "track_mood", parameters: {"source": source});

  void trackTreatmentMoodSelectorShown({String source}) => analytics.logEvent(name: "treatment_mood");

  void trackTreatmentMoodSelectorDismissed({String source}) => analytics.logEvent(name: "treatment_mood_skip");

  void onboardingSkipped() => analytics.logEvent(name: "onboarding_skipped");

  void phq9Completed(bool wasWholeTest) =>
      analytics.logEvent(name: "phq9_completed", parameters: {"fullTest": wasWholeTest});

  void phq9Open() =>
      App.isDayBreak ? analytics.logEvent(name: "emergency_contact_screen") : analytics.logEvent(name: "phq9_screen");

  void emergencyContactPressed() => App.isDayBreak
      ? analytics.logEvent(name: "emergency_contact_number_pressed")
      : analytics.logEvent(name: "phq9_number_pressed");

  void localNotificationOpened() => analytics.logEvent(name: "local_notification_opened");

  void moodCalendarDayDetailOpened() => analytics.logEvent(name: "mood_calendar_day_detail_opened");

  void notificationPrefChanged(bool isOn) =>
      analytics.logEvent(name: "notification_pref_changed", parameters: {"is_on": isOn.toString()});

  void signUpPageOpen() => analytics.logEvent(name: "sign_up");

  void signUpSuccess() => analytics.logEvent(name: "sign_up_complete");

  void signUpFailure() => analytics.logEvent(name: "sign_up_failure");

  void emailVerificationCompleted() => analytics.logEvent(name: "email_verification_completed");

  void silentException(Exception e, {String devMessage}) {
    try {
      String message = "$e";
      if (message.length > 100) {
        message = message.substring(0, 99);
      }
      analytics.logEvent(name: "silent_exception", parameters: {"toString": message, "devMessage": devMessage});
    } catch (e) {
      //
    }
  }

  void silentError(Error e, {String devMessage}) {
    try {
      String message = "$e";
      if (message.length > 100) {
        message = message.substring(0, 99);
      }
      analytics.logEvent(name: "silent_exception", parameters: {"toString": message, "devMessage": devMessage});
      print("Silent Exception: \nmessage = $message\ndevMessage = $devMessage");
    } catch (e) {
      //
    }
  }
}

void trackSilently(dynamic e, {String devMessage}) {
  if (e is String) {
    TrackingService().silentError(AssertionError(e));
  } else if (e is Exception) {
    TrackingService().silentException(e, devMessage: devMessage);
  } else if (e is Error) {
    TrackingService().silentError(e, devMessage: devMessage);
  }
}
