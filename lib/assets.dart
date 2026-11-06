import 'package:aebeze/app.dart';

class Assets {
  static const String iosShare = "res/images/share.png";
  static const String chevronDown = "res/images/chevron_down.png";
  static const String chevronFlatter = "res/images/chevron_flatter_2.png";
  static const String headerBadge = "res/images/header_badge.png";
  static const String iconShareFacebook = "res/images/icon_share_facebook.png";
  static const String iconShareTwitter = "res/images/icon_share_twitter.png";
  static const String iconShareWhatsapp = "res/images/icon_share_whatsapp.png";
  static const String iconShareMore = "res/images/icon_share_more.png";
  static const String iconFacebookCircle = "res/images/icon_facebook_circle.png";
  static const String iconEnvelope = "res/images/icon_envelope.png";
  static const String iconMessenger = "res/images/icon_messenger.png";
  static const String iconWhatsApp = "res/images/icon_whatsapp.png";
  static const String iconTelegram = "res/images/icon_telegram.png";
  static const String iconTwitter = "res/images/icon_twitter.png";
  static const String iconEmail = "res/images/icon_email.png";
  static const String iconCopyLink = "res/images/icon_copy_link.png";
  static const String iconMore = "res/images/icon_more.png";
  static const String iconEye = "res/images/icon_eye.png";
  static const String iconNoEye = "res/images/icon_no_eye.png";
  static const String iconHeartOutline = "res/images/icon_heart_outline.png";
  static const String iconHeart = "res/images/icon_heart.png";
  static const String iconGlobe = "res/images/icon_globe.png";
  static const String iconBack = "res/images/icon_back.png";
  static const String iconCross = "res/images/icon_cross.png";
  static const String iconMoreTreatments = "res/images/icon_more_treatments.png";
  static const String iconCheckMark = "res/images/icon_check_mark.png";
  static const String gabaSplashVideo = "res/videos/gaba_splash_video.mp4";
  static const String oxytocinSplashVideo = "res/videos/oxytocin_splash_video.mp4";
  static const String justSnowing = "res/videos/just_snow.mp4";
  static const String moodriseLogo = "res/images/moodrise_logo.png";
  static const String daybreakLogo = "res/images/daybreak_logo.png";
  static const String pillcastPlayButton = "res/images/icon_pillcast_play.png";
  static const String pillcastPauseButton = "res/images/icon_pillcast_pause.png";
  static const String pillcastSkipButton = "res/images/icon_pillcast_skip.png";
  static const String pillcastCheckMark = "res/images/icon_pillcast_checkmark.png";
  static const String iconPillcastTrack = "res/images/icon_pillcast_track.png";
  static const String iconCrossInCircle = "res/images/icon_cross_in_circle.png";
  static const String iconChevronInCircle = "res/images/icon_chevron_in_circle.png";
  static const String backgroundInsightsMoodrise = "res/images/background_insights_moodrise.png";
  static const String backgroundPillcastAndUserAccountMoodrise =
      "res/images/background_pillcast_and_user_account_moodrise.png";
  static const String backgroundAuthenticationMoodrise = "res/images/background_authentication_moodrise.png";
  static const String backgroundDefaultDaybreak = "res/images/background_default_daybreak.png";
  static const String iconCheckIn = "res/images/icon_check_in.png";
  static const String iconHistory = "res/images/icon_history.png";
  static final String iconPillcast = "res/images/icon_pillcast.png";
  static final String iconUserAccount =
      App.isDayBreak ? "res/images/icon_user_account_daybreak.png" : "res/images/icon_user_account_moodrise.png";

  static const String pillcastAudioTreatmentsJson = "res/json/pillcast_audio_treatments.json";

  static String sanitizeName(String name) {
    if (name == null) {
      return "serotonin";
    } else if (name.toLowerCase().contains("acetylcholine")) {
      return "acetylcholine";
    } else if (name.toLowerCase().contains("dopamine")) {
      return "dopamine";
    } else if (name.toLowerCase().contains("endorphins")) {
      return "endorphins";
    } else if (name.toLowerCase().contains("experimental")) {
      return "experimental";
    } else if (name.toLowerCase().contains("gaba")) {
      return "gaba";
    } else if (name.toLowerCase().contains("oxytocin")) {
      return "oxytocin";
    } else if (name.toLowerCase().contains("serotonin")) {
      return "serotonin";
    } else if (name.toLowerCase().contains("testosterone")) {
      return "testosterone";
    } else {
      return "serotonin";
    }
  }

  static String flavorSuffix = App.isDayBreak ? "daybreak" : "moodrise";

  static String ingredientSmallImage(String name) => "res/images/ingredient_${sanitizeName(name)}_small.png";

  static String ingredientImage(String name) => "res/images/ingredient_${sanitizeName(name)}_$flavorSuffix.png";

  static String pillcastIngredientImage(String name) => "res/images/pillcast_${flavorSuffix}_${sanitizeName(name)}.png";

  static String onboardingImage(int pageNumber) => "res/images/onboarding$pageNumber.png";
}
