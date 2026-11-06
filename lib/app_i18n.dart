import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations);

  static final Map<String, Map<String, String>> _localizedValues = {
    "en": {
      "app_name": App.appName,
      "alert_generic_netword_error_title": "WyFy? Wifi? Wai-Fai? Need it.",
      "alert_generic_netword_error_msg": "Please check your internet connection and try again.",
      "alert_generic_netword_error_action": "Retry",
      "alert_app_needs_update_error_title": "This app version is too old.",
      "alert_app_needs_update_error_msg": "Please got to the store and update it",
      "alert_app_needs_update_error_action": "Go to store",
      "dashboard_your_saved_cards": "Liked",
      "treatment_benefits": "Benefits",
      "congratulations": "Congratulations!",
      "manage_notifications": "Manage Notifications",
      "mood_tracking_notifications": "Notifications",
      "email": "Email",
      "create_account": "Create account",
      "sign_up_base": "Base",
      "sign_up_unit_squadron": "Unit/Squadron",
      "sign_up_af_specialty_code": "Air Force Specialty Code",
      "sign_up_gender_male": "Male",
      "sign_up_gender_female": "Female",
      "sign_up_gender_undisclosed": "Other/Rather not say",
      "gender": "Gender",
      "sign_up_age_range_0": "Under 24",
      "sign_up_age_range_1": "24-30",
      "sign_up_age_range_2": "31-40",
      "sign_up_age_range_3": "41-50",
      "sign_up_age_range_4": "Over 50",
      "age": "Age",
      "sign_up_shift_day": "Day",
      "sign_up_shift_mid": "Mid",
      "sign_up_shift_swing": "Swing",
      "sign_up_airbase_beale": "Beale AFB - California",
      "sign_up_airbase_edwards": "Edwards AFB - California",
      "sign_up_airbase_langley": "Langley AFB - Virginia",
      "sign_up_airbase_aludeid": "Al Udeid Air Base - Doha",
      "shift": "Shift",
      "log_in": "Log in",
      "login": "Login",
      "sign_up": "Sign up",
      "authentication_page_title": "Making moods better, one day at a time.",
      "authentication_page_description": "Understand yourself. Experience yourself. Be yourself. Trip out, man.",
      "authentication_login_page_title": "Login",
      "authentication_sign_up_page_title": "Sign Up",
      "authentication_reset_password_page_title": "Reset",
      "authentication_reset_password_button": "Reset password",
      "authentication_password_reset_description":
          "Submit your email address and we’ll send you a link to reset your password.",
      "authentication_password_reset_dialog_text": "You will receive an email with password reset shortly.",
      "authentication_sign_up_button": "Sign up",
      "authentication_already_have_account": "Already have an account?",
      "password": "Password",
      "sign_up_with_email": "Sign up with email",
      "log_in_with_facebook": "Login with Facebook",
      "sign_up_with_facebook": "Sign up with Facebook",
      "authentication_or_separator": "Or",
      "log_in_with_email": "Login with email",
      "forgot_your_password": "Forgot your password?",
      "forgot_password": "Forgot Password",
      "ok": "OK",
      "validator_email_empty": "Email can't be empty.",
      "validator_email_not_valid": "Not a valid email.",
      "validator_email_daybreak_domain": "Not a valid email for using daybreak.",
      "validator_password_empty": "Password can't be empty.",
      "validator_field_empty": "This field is required.",
      "error_user_cancel_signin": "Sign-in canceled",
      "error_network_not_available": "Please verify that the device is connected to internet",
      "error_work_in_progress": "This feature is not available yet",
      "error_permission_denied": "Your credentials have expired. Please log in again.",
      "error_server_content": "Oops... something went wrong!",
      "unknown_error": "Oops... something went wrong!",
      "user_account": "Your account",
      "user_account_settings": "Settings",
      "logged_in_as": "You are logged in as",
      "log_out": "Log out",
      "about_button": "About",
      "privacy_policy": "Privacy policy",
      "privacy_page_title": "Privacy",
      "privacy_page_sub_title": "Your privacy matters",
      "privacy_page_sub_title_2": "Strict confidentiality is our highest priority",
      "privacy_page_description":
          "Your name and data will never be shared with colleagues, superiors or commanders. Only anonymous information will be used to assess program effectiveness.",
      "privacy_page_main_text": "What you do on Daybreak is private.",
      "privacy_page_emergency_contacts_text":
          "For immediate support by phone- with identical commitments to confidentiality- we encourage you to try one of the following four(4) free resources.",
      "privacy_page_footer": "Conversations will not be reported.",
      "emergency_contacts": "Emergency contacts",
      "about_button_login_page": App.isDayBreak ? "About Daybreak" : "About Moodrise",
      "terms_page_title": "Privacy",
      "terms_page_main_text":
          "By using our suite of apps and services, you confirm that you accept these terms of use and that you agree to comply with them. If you do not agree to these terms, you must not use our site. We recommend that you print a copy of these terms for future reference. Our apps and services are directed to people residing in the United Kingdom, the United States and Canada. We do not warrant or represent that content available on or through our site is appropriate for use or available in other locations. By using the site you are representing that you are over the age of 18 and are capable of forming legally binding contracts.\n\nThe Site Does Not Provide Medical Advice.\n\nThe contents of the Moodrise and AeBeZe Websites, Mobile Apps, and Moodrise Audio program for Google Home and Alexa (including text, graphics, video images, sounds, simple games, and other digital material) are designed for entertainment purposes only. Moodrise and AeBeZe content and services are not intended to amount to advice on which you should rely and should never serve as a substitute for professional advice, diagnosis, or treatment. Always seek the advice and support of a mental health professional, physician or other qualified provider of care if you have questions or concerns about general wellbeing, a specific condition, or personal safety. Never disregard professional advice and never delay your search for immediate support in the midst of emotional pain or psychiatric distress, because of something you have read on Moodrise, AeBeZe, or otherwise. We do not warrant or represent that information we provide will meet your health or medical requirements. Reliance on any information provided by AeBeZe is solely at your own risk and we do not accept any responsibility if you do. The Moodrise app suite and AeBeZe website do not give medical advice in relation to any individual case or patient, nor does it provide medical or diagnostic services.\n\nAeBeZe Labs and Moodrise are devoted to curating, creating, and carefully packaging digital assets as doses of Digital Nutrition(TM), supported by educational resources, and published findings in peer-reviewed journals of psychological science. Content posted in, or hosted by, the Moodrise or AeBeZe mobile application routinely reference the science of psychology, and these references are meant to demonstrate how the application of psychological science can benefit daily living. Content from third parties has not been verified by Moodrise or AeBeZe and we do not warrant that any such third party content is true, accurate or complete. Where our site contains links to other sites and resources provided by third parties, these links are provided for your information only. Such links should not be interpreted as approval by us of those linked websites or information you may obtain from them. We have no control over the contents of those sites or resources. We do not accept any responsibility for any third-party website or third-party applications. AeBeZe and Moodrise materials can ease feelings of distress commonly associated with psychological ailments, but they offer no guarantee and specific results will vary. All cited scientific research and resources that appear in or on Moodrise or AeBeZe are presented not as proof, but as permission to explore new treatment tools and protocol. We expect our own ongoing research, testing, and critique, aided by the input and endeavor of others in the field, will elevate the dialogue and accelerate the pace of research to better determine how measured provisions of purposeful content may benefit society.\n\nIf you are in crisis or you think you may have an emergency, call your doctor or 911 immediately. If you're having suicidal thoughts, call 1-800-273-TALK (8255) to talk to a skilled, trained counselor at a crisis center in your area at any time (National Suicide Prevention Lifeline). If you are located outside the United States, call your local emergency line immediately.\n\nYou acknowledge and agree that AeBeZe and Moodrise are not responsible for, and will not, to the fullest extent permissible at law, be liable for, any loss or damage caused by your reliance on any information or content contained on AeBeZe or Moodrise.\n\nWe do not guarantee that our site, or any content on it, will always be available or be uninterrupted. We may suspend or withdraw or restrict the availability of all or any part of our site for business and operational reasons.\n\nWe amend these terms from time to time. Every time you wish to use our site, please check these terms to ensure you understand the terms that apply at that time. We make no representations, warranties or guarantees, whether express or implied, that the content on our site is accurate, complete or up to date.",
      "about_page_title": "About",
      "about_page_sub_title": "About ${App.appName}",
      "about_page_main_text": App.isDayBreak
          ? "Daybreak specializes in the emerging field of digital therapeutics tools, techniques, and technology engineered to help counter or combat anxiety, and address the earliest signs of depression. Our digital product suite relies on peer-reviewed scientific literature and patent-pending technology to help elevate mood, maintain gains over time, and enhance behavioral health outcomes at the population level."
          : "AeBeZe Labs, the parent company of Moodrise, specializes in the emerging field of digital therapeutics tools, techniques, and technology engineered to help counter or combat anxiety, and address the earliest signs of depression. Our digital product suite relies on peer-reviewed scientific literature and patent-pending technology to help elevate mood, maintain gains over time, and enhance behavioral health outcomes at the population level.",
      "action_options": "Your options",
      "action_selected": "You selected",
      "wildcardSmallBox": "TAP HERE",
      "share_card_message": "Check out this card on " + App.appName + "!",
      "share_menu_copy_link": "Copy link",
      "share_menu_copy_text": "Copy text",
      "share_menu_telegram": "Telegram",
      "share_menu_whatsapp": "WhatsApp",
      "share_menu_twitter": "Twitter",
      "share_menu_email": "Email",
      "share_menu_facebook": "Facebook",
      "share_menu_messenger": "Messenger",
      "share_menu_more": "More",
      "share_menu_cancel": "Done",
      "share_menu_copy_link_snackbar_message": "Link copied to clipboard. Paste away!",
      "share_menu_copy_text_snackbar_message": "Text copied to clipboard. Paste away!",
      "share_prefilled_text": "Check out this cool card on ${App.appName}!",
      "share_menu_title_for_url": "Share the joy of ${App.appName} with your friends",
      "share_menu_title_for_message": "Send Message",
      "share_button": "Share this remedy",
      "messaging_card_instructions": "Select a message to send to a friend",
      "sign_up_terms":
          "By creating an account, I consent to ${App.appName} capturing my email address for the purpose of managing my account",
      "onboarding_button_get_started": "Get started",
      "button_next": "Next",
      "button_submit": "Submit",
      "button_skip": "Skip",
      "button_done": "Done",
      "button_more": "More",
      "button_sign_up": "Sign up",
      "mood_card_placement_header": "How are you feeling?",
      "mood_card_placement_content": "Touch and place the target to reflect how you are currently feeling",
      "mood_card_placement_swipe_hint": "Swipe left or right",
      "not_a_member": "Not a member? ",
      "password_eight_characters_message": "Password must be at least 6 characters",
      "check_your_inbox": "Check\nyour inbox!",
      "check_inbox_text":
          "To continue your ${App.appName} journey please tap on the link we just sent to your email address.",
      "authentication_not_received_link": "If you haven’t received the link press:",
      "authentication_resend_verification_email_button": "Resend verification email",
      "authentication_verification_email_not_you_button": "Not you? Logout",
      "please_verify": "Please verify your email",
      "day": "day",
      "well_done": "Well done",
      "treatment_complete": "treatment complete",
      "phq9_popup_title": "Are you feeling ok?",
      "phq9_popup_description_part_1": "We’ve noticed you’ve felt a little under the weather recently.",
      "phq9_popup_description_part_2":
          "We recommend taking a 2 minute advanced mood screening to better understand how you've been feeling.",
      "phq9_daybreak_popup_description_part_2":
          "You don't have to face it alone, we can put you in contact with people that can help.",
      "phq9_popup_button": "Take the screening",
      "phq9_daybreak_popup_button": "Show me",
      "phq9_start_card_title": "Mood screening",
      "phq9_start_card_description":
          "This test shoud help you better understand how you've been feeling over the last fortnight and point you in the right direction for helpful advice and information.",
      "phq9_result_title_header": "PHQ-9 complete",
      "phq9_result_title": "Here are your results...",
      "phq9_result_sms_home_to": "HOME to 741741",
      "phq9_result_low_start":
          "Based on your responses you're not experiencing many of the symptoms seen in depression.\n\nHowever, if you have any concerns about your health or mood, please text the Crisis Text Line the word ",
      "phq9_result_low_end": " or arrange to speak to your doctor.",
      "phq9_result_medium_start":
          "Based on your responses you are experiencing some symptoms seen in depression but only an experienced health professional can tell for sure.\n\nYou should make an appointment to see your GP over the next few days or text the Crisis Text Line the word ",
      "phq9_result_medium_end": ". They can offer you confidential support.",
      "phq9_result_high_start":
          "Based on your responses you are experiencing many symptoms seen in depression but only an experienced health professional can tell for sure.\n\nYou should make an appointment to see your GP over the next few days or text the Crisis Text Line the word ",
      "phq9_result_high_end": ". They can offer you confidential support.",
      "emergency_contacts_page_title": "Contacts",
      "emergency_contacts_page_sub_title": "Free and confidential",
      "emergency_contacts_page_description": "Reach out to someone who knows how to listen.",
      "emergency_contacts_page_footer": "*All calls are kept confidential and off the record.",
      "emergency_contacts_page_1_title": "Crisis Talk",
      "emergency_contacts_page_1_number": "1-800-273-8255",
      "emergency_contacts_page_1_additional_text": "; Press 1",
      "emergency_contacts_page_2_title": "Veterans Crisis Hotline",
      "emergency_contacts_page_2_number": "1-866-966-1020",
      "emergency_contacts_page_3_title": "Beale Clinic Nurse Advice Line",
      "emergency_contacts_page_3_number": "530-634-2941",
      "emergency_contacts_page_4_title": "548 ART Chaplain Cell",
      "emergency_contacts_page_4_number": "530-755-7427",
      "dashboard_icon_history": "Insights",
      "user_account_page_check_in": "Check In",
      "dashboard_icon_check_in": "Check In",
      "dashboard_icon_pillcast": "Pillcast",
      "dashboard_icon_user_account": "Profile",
      "verification_email_snackbar": "Email sent to",
      "end_card_rating_header": "How helpful was this treatment?",
      "end_card_rating_didnt_help": "Bad",
      "end_card_rating_did_help": "Great",
      "end_card_header": "Treatment complete",
      "end_card_title": "Great Work",
      "end_card_bottom_button": "Done",
      "end_card_comment_label": "Leave a comment",
      "notification_manager_title": "Notifications",
      "notification_manager_sub_title": "Track your mood daily",
      "notification_manager_body":
          "We recommend you track your mood regularly so that you can get a view of how your mood varies over time.",
      "notification_manager_get_notified": "Send notifications",
      "card_menu_instruction_hold_to_play": "Hold to play",
      "card_menu_instruction_hold_to_resume": "Hold to resume",
      "card_menu_explanation_text_start":
          "We rely on the latest research in peer-reviewed scientific journals to inform and govern all of our programs. Current literature firmly establishes the positive effect(s) of specific neurotransmitters on particular moods. Although exposure to purely digital assets is no substitute for prescription medications, the consumption of specific materials—such as those published in Moodrise—are designed to boost ",
      "card_menu_explanation_text_end": " levels in the brain and body.",
      "card_menu_information": "Information",
      "card_menu_courtesy": "Image/Video courtesy of",
      "card_menu_reference": "Neuropsychobiology reference",
      "card_menu_more_information": "+ More information",
      "dashboard_featured_treatment": "Featured treatment",
      "dashboard_all_treatments": "All treatments",
      "start_card_menu_title": "How it works",
      "start_card_treatments": "Rewind, relax",
      "start_card_ingredient_brief": "Active ingredients",
      "start_card_suitable_for": "Suitable for",
      "start_card_warning": "When using this program",
      "start_card_days": "Day",
      "start_card_bottom_button": "Start session",
      "ask_for_review": "Ask for a review",
      "mood_selector_daybreak_how_do_you_feel": "How do you feel?",
      "mood_selector_list_im_feeling": "What are you feeling?",
      "mood_selector_list_positive": "Positive",
      "mood_selector_list_negative": "Negative",
      "mood_selector_factor_list_factors_are": "The factors are...",
      "pillcast_dashboard_title": "Pillcast",
      "pillcast_dashboard_description": "Dogs are the answer of course you say, what else could be the cause?",
      "pillcast_dashboard_and_more": "and more...",
      "pillcast_play_button": "Play",
      "pillcast_pause_button": "Pause",
      "pillcast_audio_program": "Audio Program",
      "checkins": "Check-ins",
      "checkins_count": "check-ins",
      "checkins_header_start": "You’re checking in with",
      "checkins_header_end": "this week than last.",
      "checkins_header_additional_great_work": "Great work.",
      "checkins_header_no_entry_start": "Checking-in with",
      "checkins_header_no_entry_end": "helps us recommend treatments and helps us gain insights.",
      "insights_more": "more",
      "insights_same": "as much",
      "insights_less": "less",
      "checkins_this_week": "This week",
      "checkins_last_week": "Last week",
      "emotions": "Emotions",
      "emotions_header": "Compared to last week, you’ve been feeling",
      "emotions_times_you_felt": "times you said you felt",
      "emotions_this_week": "This week",
      "emotions_last_week": "Last week",
      "factors": "Factors",
      "factors_header": "Some of the most common factors that are contributing to your emotions are related to",
      "factors_checkins_mentioned": "check-ins mentioned",
      "insights_page_title": "Insights",
    },
  };

  String string(String value) {
    String lm = _localizedValues[locale.languageCode][value];
    if (lm == null) {
      print("Warning localized string $value version for ${locale.languageCode} is not available");
      lm = _localizedValues['en'][value];
    }
    return lm;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

String localize(BuildContext context, String string) {
  AppLocalizations ap = AppLocalizations.of(context);
  if (ap == null) {
    print("Warning: app localizations is null for string: $string");
    return string;
  }
  String value = ap.string(string);
  if (value == null) {
    print("Warning: no string from AppLocalization: $string");
    return string;
  }
  return value;
}
