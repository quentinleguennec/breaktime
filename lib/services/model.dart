import 'dart:convert';
import 'dart:ui';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

String prefixCloudStorageUrl(String path) {
  if (path == null) {
    return path;
  }
  if (path.startsWith("https://") || path.startsWith("http://") || path.startsWith("res/")) {
    return path;
  }
  return App.imageUrlPrefix + path;
}

@immutable
class User {
  final String uid;
  final String email;
  final bool _isAnonymous;
  final bool _isVerified;

  bool get isAnonymous => _isAnonymous ?? true;

  User(this.uid, this.email, this._isAnonymous, this._isVerified);

  User.fromFirebase(FirebaseUser user)
      : uid = user.uid,
        email = user.email,
        _isAnonymous = user.isAnonymous,
        _isVerified = user.isEmailVerified;

  User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        email = json['email'],
        _isAnonymous = json['isAnonymous'],
        _isVerified = json['isVerfied'];

  Map<String, dynamic> toMap() => {
        "uid": uid,
        "email": email,
        "isAnonymous": isAnonymous,
      };

  bool get isVerified => !isAnonymous && (_isVerified ?? false);

  @override
  String toString() => 'User{uid: $uid, username: $email, isAnonymous: $isAnonymous}';
}

@immutable
class DataCards {
  final List<DataCard> cards;

  DataCards(this.cards);

  factory DataCards.fromJson(Map<String, dynamic> map, {String node = "results"}) {
    try {
      return DataCards(map == null || map[node] == null
          ? []
          : List<Map<String, dynamic>>.from(map[node]).map((element) => DataCard.fromJson(element)).toList());
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing DataCards");
      return DataCards([]);
    }
  }
}

@immutable
class DataCard {
  final String uid;
  final String type;
  final String title;
  final String description;
  final List<ActiveIngredient> activeIngredients;
  final Background background;
  final Placement placement;
  final String audioFile;
  final List<String> supportingSciencesUids;
  final String creator;
  final String source;
  final String slidingImage;
  final List<Action> actions;
  final WildcardData wildcardData;
  final Duration duration;
  final List<Message> messages;
  final String storyImage;
  final String storyContent;
  final int storyPosition;
  final int storyLength;
  final String storyTextColor;
  final UpsellData upsellData;
  final bool isVideoFullscreen;
  final bool isVideoLooping;
  final MoodData existingMoodData;

  DataCard({
    this.uid,
    this.type = "error",
    this.description,
    this.activeIngredients,
    this.title,
    String audioFile,
    this.background,
    this.placement,
    this.supportingSciencesUids,
    this.creator,
    this.source,
    this.slidingImage,
    this.actions,
    this.wildcardData,
    this.duration,
    this.messages,
    String storyImage,
    this.storyContent,
    this.storyPosition,
    this.storyLength,
    this.storyTextColor,
    this.upsellData,
    this.isVideoFullscreen = false,
    this.isVideoLooping = false,
    this.existingMoodData,
  })  : this.storyImage = prefixCloudStorageUrl(storyImage),
        this.audioFile = prefixCloudStorageUrl(audioFile);

  factory DataCard.fromJson(Map<String, dynamic> map) {
    try {
      return log(DataCard(
        uid: map["id"],
        type: map["type"] ?? "error",
        description: map["description"],
        activeIngredients: ActiveIngredients.fromJson(map).activeIngredients,
        title: map["title"],
        audioFile: map["audioFile"],
        background: Background(
          color: map["backgroundColor"],
          image: map["backgroundImage"],
          video: map["audioFile"] ?? map["backgroundVideo"],
        ),
        placement: map.containsKey("placement") ? Placement.fromJson(map["placement"]) : null,
        supportingSciencesUids: map["supportingSciences"] == null ? [] : map["supportingSciences"].cast<String>(),
        creator: map["creator"],
        source: map["source"],
        slidingImage: map["slidingImage"],
        actions: Actions.fromJson(map).actions,
        wildcardData: WildcardData.fromJson(map),
        upsellData: UpsellData.fromJson(map),
        duration: map["type"] == "slide" || map["duration"] == null
            ? Duration(milliseconds: 0)
            : Duration(milliseconds: map["duration"] * 1000),
        messages: Messages.fromJson(map).messages,
        storyContent: map["storyContent"],
        storyImage: prefixCloudStorageUrl(map["storyImage"]),
        storyPosition: map["storyPosition"],
        storyLength: map["storyLength"],
        storyTextColor: map["storyTextColor"],
        isVideoFullscreen: map["videoFullscreen"] ?? false,
        isVideoLooping: map["videoLoop"] ?? false,
      ));
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing DataCard");
      return null;
    }
  }

  static DataCard log(DataCard card) {
    if (App.httpCardsLogsOn) print("CARD: ${card.type} - ${card.uid}");
    return card;
  }

  bool isSupported() =>
      isBasicCard() ||
      isAudioCard() ||
      isVideoCard() ||
      isDragCard() ||
      isMessagingCard() ||
      isWildcardCard() ||
      isUpsellCard() ||
      isStoryCard() ||
      isStartCard() ||
      isEndCard() ||
      isErrorCard();

  bool isBasicCard() => type == "basic";

  bool isAudioCard() => type == "audio";

  bool isVideoCard() => type == "video";

  bool isDragCard() => type == "drag";

  bool isWildcardCard() => type == "wildcard";

  bool isMessagingCard() => type == "messaging";

  bool isStoryCard() => type == "story";

  bool isErrorCard() => type == "error";

  bool isStartCard() => type == "start";

  bool isEndCard() => type == "end";

  bool isUpsellCard() => type == "upsell";

  bool isPHQ9StartCard() => type == "phq9_start";

  bool isPHQ9QuestionCard() => type == "phq9_question";

  bool isPHQ9ResultCard() => type == "phq9_result";

  bool hasBackgroundImage() => background != null && background.image != null;

  bool hasBackgroundVideo() => background != null && background.video != null;

  bool hasActions() => actions != null && actions.isNotEmpty;

  bool hasSupportingSciences() => supportingSciencesUids != null && supportingSciencesUids.isNotEmpty;

  bool hasCredits() => (creator != null && creator.isNotEmpty) || (source != null && source.isNotEmpty);

  bool hasTimer() => duration != null && duration.inSeconds > 0;

  @override
  String toString() {
    return 'DataCard{type: $type, description: $description}';
  }

  @override
  bool operator ==(dynamic other) => other.runtimeType == runtimeType && other.uid == uid;

  @override
  int get hashCode => uid.hashCode;
}

@immutable
class WildcardData {
  final Background background;
  final String headline;
  final String text;
  final String boxColor;

  WildcardData({this.background, this.headline, this.text, this.boxColor});

  factory WildcardData.fromJson(Map<String, dynamic> map) {
    try {
      return WildcardData(
        headline: map["wildcardHeadline"],
        text: map["wildcardText"],
        boxColor: map["wildcardBoxColor"],
        background: Background(
          color: map["wildcardBackgroundColor"],
          image: map["wildcardBackgroundImage"],
          video: map["wildcardBackgroundVideo"],
        ),
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Chemicals");
      return null;
    }
  }

  bool hasVideo() => background != null && background.video != null;

  bool hasBackgroundImage() => background != null && background.image != null;
}

@immutable
class UpsellData {
  final String text;
  final String link;

  UpsellData({this.text, this.link});

  factory UpsellData.fromJson(Map<String, dynamic> map) {
    try {
      UpsellData data = UpsellData(link: map['upsellLink'], text: map['upsellText']);
      return data;
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Upsell");
      return null;
    }
  }
}

@immutable
class Background {
  final String video;
  final String image;
  final String color;
  final Gradient gradient;

  Background({String video, this.color, String image, this.gradient})
      : this.image = prefixCloudStorageUrl(image),
        this.video = prefixCloudStorageUrl(video);

  bool get hasImage => image != null && image.isNotEmpty;
}

@immutable
class Placement {
  final String type;
  final String content;
  final String header;

  // Override (not using backend value anymore).
  final String textColor = "0xFFFFFFFF";

  // Override (not using backend value anymore).
  final Background background = Background(color: "0x00000000");

  // textColor and background are not used on purpose here (overridden).
  // TODO: remove the parameter altogether if we go with this idea.
  Placement({this.type = "bottom", this.header, this.content, textColor, background});

  factory Placement.fromJson(Map<String, dynamic> map) {
    try {
      return Placement(
        type: map["type"],
        header: map["header"],
        content: map["content"],
        textColor: map["textColor"],
        background: Background(color: map["backgroundColor"]),
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Placement");
      return null;
    }
  }

  @override
  String toString() {
    return 'Placement{type: $type, content: $content, header: $header, textColor: $textColor, background: $background}';
  }
}

@immutable
class ActiveIngredients {
  final List<ActiveIngredient> activeIngredients;

  ActiveIngredients(this.activeIngredients);

  factory ActiveIngredients.fromJson(Map<String, dynamic> map, {node = "chemicals"}) {
    try {
      return ActiveIngredients(map == null || map[node] == null
          ? []
          : List<Map<String, dynamic>>.from(map[node]).map((element) => ActiveIngredient.fromJson(element)).toList());
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing ActiveIngredients");
      return ActiveIngredients([]);
    }
  }
}

@immutable
class ActiveIngredient {
  final String uid;
  final String code;
  final String name;
  final String description;
  final List<String> supportingSciencesUids;

  ActiveIngredient({
    this.uid,
    this.code,
    this.name,
    this.description,
    this.supportingSciencesUids,
  });

  factory ActiveIngredient.fromJson(Map<String, dynamic> map) {
    try {
      return ActiveIngredient(
        uid: map["uid"],
        code: map["code"],
        name: map["name"],
        description: map["description"],
        supportingSciencesUids: SupportingSciences.fromJson(map, node: "supportingSciences")
            .supportingSciences
            .map((ss) => ss.uid)
            .toList(),
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing ActiveIngredient");
      return null;
    }
  }

  @override
  String toString() {
    return 'ActiveIngredient{uid: $uid, code: $code, name: $name, description: $description, supportingSciencesUids: $supportingSciencesUids}';
  }

  @override
  bool operator ==(dynamic other) => other.runtimeType == runtimeType && other.name == name && other.code == code;

  @override
  int get hashCode => name.hashCode;
}

@immutable
class SupportingSciences {
  final List<SupportingScience> supportingSciences;

  SupportingSciences(this.supportingSciences);

  factory SupportingSciences.fromJson(Map<String, dynamic> map, {node = "results"}) {
    try {
      return SupportingSciences(map == null || map[node] == null
          ? []
          : List<Map<String, dynamic>>.from(map[node]).map((element) => SupportingScience.fromJson(element)).toList());
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing SupportingSciences");
      return SupportingSciences([]);
    }
  }
}

@immutable
class SupportingScience {
  final String uid;
  final String source;
  final String date;
  final List<String> tags;
  final String title;
  final String authors;
  final String doi;
  final String content;
  final String url;

  SupportingScience({
    this.uid,
    this.source,
    this.date,
    this.title,
    this.url,
    this.tags,
    this.authors,
    this.doi,
    this.content,
  });

  factory SupportingScience.fromJson(Map<String, dynamic> map) {
    try {
      return SupportingScience(
        uid: map["id"],
        source: map["source"],
        date: map["date"],
        title: map["title"],
        url: map["url"],
        tags: map["tags"] == null ? [] : map["tags"].cast<String>(),
        authors: map["authors"],
        doi: map["doi"],
        content: map["content"],
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing SupportingScience");
      return null;
    }
  }
}

@immutable
class Treatments {
  final List<Treatment> treatments;

  Treatments(this.treatments);

  factory Treatments.fromJson(Map<String, dynamic> map, {node = "results"}) {
    try {
      return Treatments(map == null || map[node] == null
          ? []
          : List<Map<String, dynamic>>.from(map[node]).map((element) => Treatment.fromJson(element)).toList());
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Treatments");
      return Treatments([]);
    }
  }
}

@immutable
class Treatment {
  static const String defaultColor = "0xFFFFFFFF";
  static const String specialSavedCardTreatmentUid = "special_saved_card";
  static const String specialDeepLinkTreatmentUid = "special_deep_link";
  static const String specialMoodSelectorTreatmentUid = "special_mood_selector";

  final String uid;
  final String name;
  final String description;
  final List<String> benefits;
  final String directions;
  final String icon;
  final String type;
  final List<DataCard> cards;
  final bool featured;
  final List<Color> gradientColors;
  final List<ActiveIngredient> activeIngredients;
  final int day;
  final String color;
  final String ingredientsBrief;
  final String warning;
  final String suitableFor;

  Treatment({
    this.uid,
    this.name,
    this.description,
    this.benefits,
    this.directions,
    this.icon,
    this.type,
    this.cards,
    this.featured,
    this.gradientColors,
    this.activeIngredients,
    this.day,
    this.color = defaultColor,
    this.ingredientsBrief,
    this.warning,
    this.suitableFor,
  });

  factory Treatment.fromJson(Map<String, dynamic> map) {
    try {
      return Treatment(
        uid: map["uid"],
        name: map["name"],
        description: map["description"],
        benefits: map["benefits"] == null ? [] : map["benefits"].cast<String>(),
        directions: map["directions"],
        icon: map["icon"],
        type: map["type"],
        color: map["color"],
        ingredientsBrief: map["ingredientsBrief"],
        warning: map["warning"],
        suitableFor: map["suitableFor"],
        cards: DataCards.fromJson(map, node: "cards").cards,
        featured: map["featured"],
        gradientColors: map["gradientColors"] == null
            ? <Color>[
                stringToColor(map["gradientColor1"]) ?? Colors.white,
                stringToColor(map["gradientColor2"]) ?? Colors.grey
              ]
            : map["gradientColors"].cast<String>().map((e) => stringToColor(e)).toList().cast<Color>(),
        activeIngredients: ActiveIngredients.fromJson(map, node: "chemicals").activeIngredients,
        day: map["day"],
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Treatment");
      return null;
    }
  }

  factory Treatment.fromSavedCard(DataCard card) => Treatment(
        uid: specialSavedCardTreatmentUid,
        cards: [card],
      );

  factory Treatment.fromDeepLinkCard(DataCard card) => Treatment(
        uid: specialDeepLinkTreatmentUid,
        cards: [card],
      );

  @override
  String toString() => 'Treatment{uid: $uid, name: $name, type: $type, day: $day}';

  bool get isSpecial => isSavedCard || isMoodSelector || isDeepLinkCard;

  bool get isSavedCard => uid == specialSavedCardTreatmentUid;

  bool get isMoodSelector => uid == specialMoodSelectorTreatmentUid;

  bool get isDeepLinkCard => uid == specialDeepLinkTreatmentUid;
}

@immutable
class Actions {
  final List<Action> actions;

  Actions(this.actions);

  factory Actions.fromJson(Map<String, dynamic> map, {node = "actions"}) {
    try {
      return Actions(map == null || map[node] == null
          ? []
          : List<Map<String, dynamic>>.from(map[node]).map((element) => Action.fromJson(element)).toList());
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Actions");
      return Actions([]);
    }
  }
}

@immutable
class Action {
  final String choice;
  final String result;

  Action({this.choice, this.result});

  factory Action.fromJson(Map<String, dynamic> map) {
    try {
      return Action(
        choice: map["choice"],
        result: map["result"],
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Action");
      return null;
    }
  }
}

@immutable
class Messages {
  final List<Message> messages;

  Messages(this.messages);

  factory Messages.fromJson(Map<String, dynamic> map, {node = "messages"}) {
    try {
      return Messages(map == null || map[node] == null
          ? []
          : List<Map<String, dynamic>>.from(map[node]).map((message) => Message.fromJson(message)).toList());
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Messages");
      return Messages([]);
    }
  }
}

@immutable
class Message {
  final String backgroundColor;
  final String textColor;
  final String message;
  final double rotation;
  final double horizontalTranslation;
  final double verticalTranslation;

  Message({
    this.textColor,
    this.rotation,
    this.horizontalTranslation,
    this.verticalTranslation,
    this.backgroundColor,
    this.message,
  });

  factory Message.fromJson(Map<String, dynamic> map) {
    try {
      return Message(
        backgroundColor: map["backgroundColor"],
        textColor: map["textColor"],
        message: map["message"],
        rotation: double.parse("${map["rotation"]}"),
        horizontalTranslation: double.parse("${map["x"]}"),
        verticalTranslation: double.parse("${map["y"]}"),
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing Message");
      return null;
    }
  }
}

@immutable
class MoodData {
  static const int lowMoodLimit = -4;

  final Mood mood;
  final DateTime date;
  final List<String> feelings;
  final List<String> factors;

  MoodData({
    @required this.mood,
    @required this.date,
    this.feelings = const [],
    this.factors = const [],
  });

  @override
  String toString() {
    return 'MoodData{mood: $mood, date: $date}';
  }

  bool get positive => mood.positive;
}

@immutable
class Mood {
  final int value;
  final String text;

  Mood(this.value, this.text);

  bool get isValid => Moods.isMoodValid(this);

  @override
  String toString() => 'Mood{value: $value, text: $text}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Mood && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  bool get positive => value >= 0;
}

@immutable
class Moods {
  // Should always be an odd number of values and ordered from best to worst.
  static const List<String> _texts = [
    "Euphoric",
    "Ecstatic",
    "Excellent",
    "Pretty Great",
    "Pretty Good",
    "Fine",
    "So-so",
    "Eh",
    "Not So Good",
    "Depressed",
    "On the brink",
  ];

  static final Moods _singleton = Moods._internal();

  static final int count = _texts.length;

  static final int highestValue = _texts.length ~/ 2;

  final List<Mood> moods = List<Mood>.unmodifiable(
    List<Mood>.generate(
      _texts.length,
      (index) => Mood(
        highestValue - index,
        _texts[index],
      ),
    ),
  );
  final int length = _texts.length;

  factory Moods() => _singleton;

  static bool isMoodValid(Mood mood) =>
      mood.value <= Moods().moods.first.value && mood.value >= Moods().moods.last.value;

  Moods._internal();
}

enum DeviceType { phone, watch }

class NotificationPayload {
  final String screen; //just 'mood_selector' for now

  NotificationPayload({this.screen});

  factory NotificationPayload.fromJson(Map<String, dynamic> map) {
    try {
      if (App.notificationLogsOn) print("Notification received $map");
      //TODO Firebase notification are more complex i.e. {notification: {}, data: {collapse_key: com.aebeze.dev, google.original_priority: high, google.sent_time: 1564132552181, google.delivered_priority: high, google.ttl: 2419200, from: 571220661874, click_action: FLUTTER_NOTIFICATION_CLICK, google.message_id: 0:1564132552328728%5301778653017786}}
      return NotificationPayload(screen: map["screen"]);
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing NotificationPayload");
      return null;
    }
  }

  bool get isMoodSelector => screen == "mood_selector";

  @override
  String toString() => 'NotificationPayload{screen: $screen}';
}

@immutable
class TreatmentTrackingData {
  final String treatmentUid;
  final int cardsCompletedCount;
  final int rating;
  final String comment;
  final bool recommended;
  final String userUid;
  final int timestamp;

  TreatmentTrackingData(
    this.treatmentUid,
    this.recommended, {
    this.cardsCompletedCount,
    this.rating,
    this.comment,
    this.userUid,
    this.timestamp,
  });

  TreatmentTrackingData cloneWith(
      {int cardsCompletedCount, int rating, String comment, String userUid, int timestamp}) {
    return TreatmentTrackingData(
      this.treatmentUid,
      this.recommended,
      cardsCompletedCount: cardsCompletedCount ?? this.cardsCompletedCount,
      rating: rating ?? this.rating,
      comment: comment != null && comment.trim().isNotEmpty ? comment.trim() : this.comment,
      userUid: userUid ?? this.userUid,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  String asJsonBody() {
    Map body = {
      "userUid": userUid,
      "treatmentUid": treatmentUid,
      "timestamp": timestamp,
      "cardsCompletedCount": cardsCompletedCount,
      "recommended": recommended,
    };
    if (comment != null && comment.trim().isNotEmpty) body['comment'] = comment;
    if (rating != null) body['rating'] = rating;
    return jsonEncode(body);
  }
}

@immutable
class PillcastAudioTreatments {
  final List<PillcastAudioTreatment> treatments;

  PillcastAudioTreatments(this.treatments);

  factory PillcastAudioTreatments.fromJson(Map<String, dynamic> map, {node = "audioTreatments"}) {
    try {
      return PillcastAudioTreatments(
        map == null || map[node] == null
            ? []
            : List<Map<String, dynamic>>.from(map[node])
                .map((element) => PillcastAudioTreatment.fromJson(element))
                .toList(),
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing PillcastAudioTreatments");
      return PillcastAudioTreatments([]);
    }
  }
}

@immutable
class PillcastAudioTreatment {
  final String uid;
  final String name;
  final String type;
  final String activeIngredient;
  final String color;
  final List<Color> gradientColors;
  final List<PillcastAudioTrack> tracks;

  PillcastAudioTreatment({
    this.uid,
    this.name,
    this.type,
    this.activeIngredient,
    this.color,
    this.gradientColors,
    this.tracks,
  });

  factory PillcastAudioTreatment.fromJson(Map<String, dynamic> map) {
    try {
      return PillcastAudioTreatment(
        uid: map["uid"],
        name: map["name"],
        type: map["type"],
        activeIngredient: map["activeIngredient"],
        color: map["color"],
        gradientColors: map["gradientColors"].cast<String>().map((e) => stringToColor(e)).toList().cast<Color>(),
        tracks: PillcastAudioTracks.fromJson(map).tracks,
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing PillcastAudioTreatment");
      return null;
    }
  }

  getDescriptionText(BuildContext context) =>
      "${tracks?.take(2)?.map((track) => track.name)?.join(", ")}, ${localize(context, "pillcast_dashboard_and_more")}";
}

@immutable
class PillcastAudioTracks {
  final List<PillcastAudioTrack> tracks;

  PillcastAudioTracks(this.tracks);

  factory PillcastAudioTracks.fromJson(Map<String, dynamic> map, {node = "tracks"}) {
    try {
      return PillcastAudioTracks(
        map == null || map[node] == null
            ? []
            : List<Map<String, dynamic>>.from(map[node])
                .map((element) => PillcastAudioTrack.fromJson(element))
                .toList(),
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing PillcastAudioTracks");
      return PillcastAudioTracks([]);
    }
  }
}

@immutable
class PillcastAudioTrack {
  final String uid;
  final String url;
  final String name;

  PillcastAudioTrack({this.uid, this.name, this.url});

  factory PillcastAudioTrack.fromJson(Map<String, dynamic> map) {
    try {
      return PillcastAudioTrack(
        uid: map["uid"],
        name: map["name"],
        url: map["url"],
      );
    } catch (e) {
      trackSilently(e, devMessage: "Error parsing PillcastAudioTrack");
      return null;
    }
  }
}
