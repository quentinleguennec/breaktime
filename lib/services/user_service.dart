import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:aebeze/app.dart';
import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/local_notification_service.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_repository.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/utils/view_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_utils/date_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _moodTrackingV2FirebaseKey = "mood_tracking_v2";
  static const String _completedTreatmentsFirebaseKey = "completed_treatments";
  static const String _fcmTokensFirebaseKey = "fcm_tokens";
  static const String _savedCardsFirebaseKey = "saved_cards";
  static const String _treatmentRatingsFirebaseKey = "treatment_ratings";
  static const String _usersFirebaseKey = "users";
  static const String _pillcastCollectionFirebaseKey = "pillcast";
  static const String _lastOpenedTreatmentsDayFirebaseKey = "last_opened_treatments_day";
  static const String _lastDateAppStartMoodSelectorWasShownPrefKey = "lastDateAppStartMoodSelectorWasShown";

  final Api _api;
  final UserRepository _userRepository;
  final MemoryCache _cache;
  final TrackingService _trackingService;
  final LocalNotificationService _localNotificationService;

  UserService(this._api, this._userRepository, this._cache, this._trackingService, this._localNotificationService);

  int get timestamp => DateTime.now().millisecondsSinceEpoch;

  Future<bool> needOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool needOnboarding = prefs.getBool("needOnboarding") ?? true;
    if (needOnboarding) {
      await prefs.setBool("needOnboarding", false);
    }
    return needOnboarding;
  }

  /// Store the mood in SharedPreferences and check if the PHQ9 form should be shown to the user.
  ///
  /// PHQ9 should be shown if a low value is reported 2 days in a row. Only the lowest value reported on a day is saved for this purpose.
  Future<bool> checkIfNeedPHQ9(int moodValue) async {
    final String oldLowestMoodValuePrefKey = "oldLowestMoodValue";
    final String newLowestMoodValuePrefKey = "newLowestMoodValue";
    final String newLowestMoodDatePrefKey = "newLowestMoodDate";
    final String lastDatePHQ9WasShownPrefKey = "lastDatePHQ9WasShown";
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int oldLowestMoodValue = 0;
    int newLowestMoodValue = 0;
    try {
      oldLowestMoodValue = prefs.getInt(oldLowestMoodValuePrefKey) ?? 0;
      newLowestMoodValue = prefs.getInt(newLowestMoodValuePrefKey) ?? 0;
    } on TypeError catch (_) {
      prefs.setInt(oldLowestMoodValuePrefKey, null);
      prefs.setInt(newLowestMoodValuePrefKey, null);
    }

    DateTime newLowestMoodDate;
    try {
      newLowestMoodDate = DateTime.parse(prefs.getString(newLowestMoodDatePrefKey) ?? "2000-01-01T00:00:00");
    } on FormatException catch (_) {
      newLowestMoodDate = DateTime(2000, 1, 1, 0, 0, 0);
    }
    DateTime lastDatePHQ9WasShown;
    try {
      lastDatePHQ9WasShown = DateTime.parse(prefs.getString(lastDatePHQ9WasShownPrefKey) ?? "2000-01-01T00:00:00");
    } on FormatException catch (_) {
      lastDatePHQ9WasShown = DateTime(2000, 1, 1, 0, 0, 0);
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    if (today.difference(newLowestMoodDate).inSeconds > 0) {
      oldLowestMoodValue = newLowestMoodValue;
      newLowestMoodDate = today;
      newLowestMoodValue = moodValue;
      await prefs.setInt(oldLowestMoodValuePrefKey, oldLowestMoodValue);
      await prefs.setString(newLowestMoodDatePrefKey, dateToString(newLowestMoodDate));
      await prefs.setInt(newLowestMoodValuePrefKey, newLowestMoodValue);
    }

    if (moodValue < newLowestMoodValue) {
      newLowestMoodValue = moodValue;
      await prefs.setInt(newLowestMoodValuePrefKey, newLowestMoodValue);
    }

    if (moodValue < MoodData.lowMoodLimit &&
        oldLowestMoodValue < MoodData.lowMoodLimit &&
        today.difference(lastDatePHQ9WasShown).inSeconds > 0) {
      await prefs.setString(lastDatePHQ9WasShownPrefKey, dateToString(today));
      return true;
    }

    return false;
  }

  Future<bool> checkIfNeedToShowAppStartMoodSelector() async {
    User user = await getUser();
    if (user.isAnonymous) {
      return false;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime lastDate =
        DateTime.parse(prefs.getString(_lastDateAppStartMoodSelectorWasShownPrefKey) ?? "2000-01-01T00:00:00");
    return !Utils.isSameDay(DateTime.now(), lastDate);
  }

  Future<void> updateAppStartMoodSelectorLastOpenDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDateAppStartMoodSelectorWasShownPrefKey, dateToString(DateTime.now()));
  }

  Future<bool> loginWithFacebook() =>
      checkExceptions(_loginFacebookUser().then((user) => _userRepository.persistUser(User.fromFirebase(user))));

  Future<FirebaseUser> _loginFacebookUser() async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);

    FacebookLoginResult result = await FacebookLogin().logInWithReadPermissions(['email']);
    final AuthCredential credential = FacebookAuthProvider.getCredential(
      accessToken: result.accessToken.token,
    );
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        FirebaseUser firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        if (firebaseUser == null) {
          if (App.inDebugMode) print("Facebook SignIn: firebase user is null, probably user cancelled");
          throw ApiException("error_user_cancel_signin");
        } else {
          User user = await getUser();
          if (user.isAnonymous) {
            await _copyUserDataToLoggedInUser(userId: firebaseUser.uid, anonymousUserDataQuery: userDataQuery);
          }
          await _userRepository.persistUser(User.fromFirebase(firebaseUser));
          await _localNotificationService.resetNotifications();
        }
        return firebaseUser;
      case FacebookLoginStatus.cancelledByUser:
        if (App.inDebugMode) print("Facebook SignIn: User cancelled");
        throw ApiException("error_user_cancel_signin");
      case FacebookLoginStatus.error:
      default:
        throw ApiException("unknown_error");
    }
  }

  Future<bool> login(String email, String password) => checkExceptions(_login(email, password));

  Future<bool> _login(String email, String password) async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);

    FirebaseUser firebaseUser =
        (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;

    bool success = await _userRepository.persistUser(User.fromFirebase(firebaseUser));
    if (user.isAnonymous) {
      await _copyUserDataToLoggedInUser(userId: firebaseUser.uid, anonymousUserDataQuery: userDataQuery);
    }
    await _localNotificationService.resetNotifications();
    return success;
  }

  Future<void> _copyUserDataToLoggedInUser(
      {@required String userId, @required DocumentSnapshot anonymousUserDataQuery}) async {
    if (anonymousUserDataQuery == null) {
      return;
    }

    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    DocumentReference userDataDocRef = userDataQuery.reference;
    Map<String, dynamic> existingUserData = fixFirestoreMapType(userDataQuery.data);
    Map<String, dynamic> anonymousUserData = fixFirestoreMapType(anonymousUserDataQuery.data);

    List<String> keysToCopy = [
      _moodTrackingV2FirebaseKey,
      _completedTreatmentsFirebaseKey,
      _fcmTokensFirebaseKey,
      _savedCardsFirebaseKey,
      _treatmentRatingsFirebaseKey
    ];

    for (String keyToCopy in keysToCopy) {
      if (anonymousUserData.containsKey(keyToCopy)) {
        var data = anonymousUserData[keyToCopy];
        if (data is List) {
          await userDataDocRef.updateData({keyToCopy: FieldValue.arrayUnion(data)});
        } else if (data is Map) {
          final Map newMap = Map<String, dynamic>.from(data)..addAll(existingUserData[keyToCopy]);
          await userDataDocRef.updateData({keyToCopy: newMap});
        } else {
          await userDataDocRef.updateData({keyToCopy: data});
        }
      }
    }
  }

  Future<bool> isUserLoggedIn() =>
      getUser().then((User user) => user != null && !user.isAnonymous).catchError((_) => false);

  Future<User> getUser() async {
    User user = await checkExceptions(_userRepository.getUser());
    if (user == null) {
      user = User.fromFirebase((await FirebaseAuth.instance.signInAnonymously()).user);
      await _userRepository.persistUser(user);
    } else if (!user.isAnonymous && !user.isVerified) {
      //!user.isVerified => Double checking to fix inconsistency of old version
      FirebaseUser firebaseUser = await _getUpdatedFirebaseUser();
      if (firebaseUser == null) {
        user = User.fromFirebase((await FirebaseAuth.instance.signInAnonymously()).user);
      } else {
        user = User.fromFirebase(firebaseUser);
      }
      await _userRepository.persistUser(user);
    }
    _trackingService.updateUser(user);
    return user;
  }

  Future<void> addFcmToken(String token) async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return;
    }
    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    if (!userData.containsKey(_fcmTokensFirebaseKey)) {
      userData.addAll({
        _fcmTokensFirebaseKey: [token]
      });

      await userDataQuery.reference.setData(userData);
    } else {
      List<String> fcmTokens = List<String>.from(userData[_fcmTokensFirebaseKey]);

      if (!fcmTokens.contains(token)) {
        fcmTokens.add(token);
      }

      await userDataQuery.reference.updateData({_fcmTokensFirebaseKey: fcmTokens});
    }
  }

  Future<FirebaseUser> _getUpdatedFirebaseUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      return null;
    }
    await user.reload();
    return user;
  }

  Future<void> logout() => checkExceptions(_logout());

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    _cache.clearUserData();
    await _userRepository.reset();
    await _localNotificationService.resetNotifications();
  }

  Future<void> signUpNewUser(
    String email,
    String password, {
    String airforceBase,
    String airforceUnitSquadron,
    String airforceSpecialtyCode,
    String gender,
    String ageRange,
    String airforceShift,
  }) =>
      checkExceptions(_signUpNewUser(
        email,
        password,
        airforceBase: airforceBase,
        airforceUnitSquadron: airforceUnitSquadron,
        airforceSpecialtyCode: airforceSpecialtyCode,
        gender: gender,
        ageRange: ageRange,
        airforceShift: airforceShift,
      ));

  Future<void> _signUpNewUser(
    String email,
    String password, {
    String airforceBase,
    String airforceUnitSquadron,
    String airforceSpecialtyCode,
    String gender,
    String ageRange,
    String airforceShift,
  }) async {
    FirebaseUser firebaseUser =
        (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user;
    await firebaseUser.sendEmailVerification();
    await _userRepository.persistUser(User.fromFirebase(firebaseUser));
    if (App.isDayBreak) {
      await saveNewDaybreakUserData(
        email,
        password,
        airforceBase,
        airforceUnitSquadron,
        airforceSpecialtyCode,
        gender,
        ageRange,
        airforceShift,
      );
    }
  }

  Future<void> saveNewDaybreakUserData(
    String email,
    String password,
    String airforceBase,
    String airforceUnitSquadron,
    String airforceSpecialtyCode,
    String gender,
    String ageRange,
    String airforceShift,
  ) async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return;
    }
    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    userData["airforceBase"] = airforceBase;
    userData["airforceUnitSquadron"] = airforceUnitSquadron;
    userData["airforceSpecialtyCode"] = airforceSpecialtyCode;
    userData["gender"] = gender;
    userData["ageRange"] = ageRange;
    userData["airforceShift"] = airforceShift;
    await userDataQuery.reference.setData(userData);
  }

  Future<void> resetPassword(String email) =>
      checkExceptions(FirebaseAuth.instance.sendPasswordResetEmail(email: email));

  Future<Null> createUserData(User user) => checkExceptions(_createUserData(user));

  Future<Null> _createUserData(User user) async {
    QuerySnapshot query =
        await Firestore.instance.collection(_usersFirebaseKey).where("uid", isEqualTo: user.uid).getDocuments();

    if (query.documents.isNotEmpty) {
      assert(query.documents.length == 1 && query.documents.first.data["email"] == user.email,
          "ERROR: duplicated users for uid = ${user.uid} and emails = '${user.email}' and '${query.documents.first.data["email"]}'.");
      return Future<Null>.value(null);
    }

    try {
      if (!user.isAnonymous) {
        query =
            await Firestore.instance.collection(_usersFirebaseKey).where("email", isEqualTo: user.email).getDocuments();
        if (query.documents.isNotEmpty) {
          assert(query.documents.length == 1 && query.documents.first.data["uid"] == user.uid,
              "ERROR: duplicated users for email = ${user.email} and uids = '${user.uid}' and '${query.documents.first.data["uid"]}'.");
          return Future<Null>.value(null);
        }
      }
    } catch (e) {
      print(e);
    }

    await Firestore.instance.collection(_usersFirebaseKey).document().setData(user.toMap());

    return Future<Null>.value(null);
  }

  Future<List<DataCard>> fetchSavedCards() => checkExceptions(_fetchSavedCards());

  Future<List<DataCard>> _fetchSavedCards() async {
    User user = await getUser();

    if (user == null || user.isAnonymous) {
      return List<DataCard>();
    }

    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return Future<Null>.value(null);
    }

    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    if (userData[_savedCardsFirebaseKey] == null) {
      return Future<Null>.value(null);
    }

    List<Map<String, dynamic>> savedCardsMaps = List<Map<String, dynamic>>.from(userData[_savedCardsFirebaseKey]);
    List<String> cardsUids = savedCardsMaps.map((cardMap) => cardMap["card_uid"] as String).toList();
    return await _api.fetchPublishedCards(cardsUids);
  }

  /// This is a hack to prevent type issues because firestore returns invalid Map<dynamic, dynamic> in the nested maps instead of Map<String, dynamic>.
  Map<String, dynamic> fixFirestoreMapType(Map<String, dynamic> map) {
    return json.decode(json.encode(map));
  }

  Future<Null> saveCard(DataCard card) => checkExceptions(_saveCard(card));

  Future<Null> _saveCard(DataCard card) async {
    if (card == null) {
      return Future<Null>.value(null);
    }

    final bool cardExists = _cache.savedCards.any((savedCard) => savedCard == card);
    if (!cardExists) {
      _cache.savedCards.add(card);
    }

    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null || user.isAnonymous) {
      return Future<Null>.value(null);
    }

    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    if (!userData.containsKey(_savedCardsFirebaseKey)) {
      userData.addAll({
        _savedCardsFirebaseKey: [
          {
            "card_uid": card.uid,
            "dose_color": Treatment.defaultColor,
          }
        ]
      });
      await userDataQuery.reference.setData(userData);
    } else {
      List<Map<String, dynamic>> savedCards = List<Map<String, dynamic>>.from(userData[_savedCardsFirebaseKey]);
      if (savedCards.any((savedCard) => savedCard["card_uid"] == card.uid)) {
        // Card already saved
        return Future<Null>.value(null);
      } else {
        savedCards.add({
          "card_uid": card.uid,
          "dose_color": Treatment.defaultColor,
        });
        await userDataQuery.reference.updateData({_savedCardsFirebaseKey: savedCards});
      }

      return Future<Null>.value(null);
    }
  }

  Future<Null> removeSavedCard(DataCard card) => checkExceptions(_removeSavedCard(card));

  Future<Null> _removeSavedCard(DataCard card) async {
    if (card == null) {
      return Future<Null>.value(null);
    }

    _cache.savedCards.removeWhere((savedCard) => savedCard == card);

    User user = await getUser();

    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null || user.isAnonymous) {
      return Future<Null>.value(null);
    }

    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    if (userData.containsKey(_savedCardsFirebaseKey)) {
      List<Map<String, dynamic>> savedCards = List<Map<String, dynamic>>.from(userData[_savedCardsFirebaseKey]);
      savedCards.removeWhere((savedCard) => savedCard["card_uid"] == card.uid);

      await userDataQuery.reference.updateData({_savedCardsFirebaseKey: savedCards});
    }
    return Future<Null>.value(null);
  }

  Future<DocumentSnapshot> _fetchUserData(User user) async {
    if (user == null) return null;

    QuerySnapshot userDataQuery = await Firestore.instance
        .collection(_usersFirebaseKey)
        .where("uid", isEqualTo: user.uid)
        .limit(1)
        .getDocuments();

    if (userDataQuery.documents.isEmpty) {
      await createUserData(user);
      userDataQuery = await Firestore.instance
          .collection(_usersFirebaseKey)
          .where("uid", isEqualTo: user.uid)
          .limit(1)
          .getDocuments();
    }

    return userDataQuery.documents.first;
  }

  Future<Map<String, Map<String, int>>> getCompletedTreatments() => checkExceptions(_getCompletedTreatments());

  Future<Map<String, Map<String, int>>> _getCompletedTreatments() async {
    User user = await getUser();
    if (user == null) {
      return Map<String, Map<String, int>>();
    }

    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return Map<String, Map<String, int>>();
    }

    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    if (userData[_completedTreatmentsFirebaseKey] == null) {
      return Map<String, Map<String, int>>();
    }

    return Map<String, Map<String, dynamic>>.from(userData[_completedTreatmentsFirebaseKey]).map(
      (key, value) => MapEntry(
        key,
        Map<String, int>.from(
          value.map(
            (key, value) => MapEntry<String, int>(key, value),
          ),
        ),
      ),
    );
  }

  Future<Null> saveCompletedTreatments(Map<String, Map<String, int>> completedTreatments) =>
      checkExceptions(_saveCompletedTreatments(completedTreatments));

  Future<Null> _saveCompletedTreatments(Map<String, Map<String, int>> completedTreatments) async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return null;
    }

    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    if (!userData.containsKey(_completedTreatmentsFirebaseKey)) {
      userData.addAll({_completedTreatmentsFirebaseKey: completedTreatments.map((key, value) => MapEntry(key, value))});

      await userDataQuery.reference.setData(userData);
    } else {
      Map<String, Map<String, int>> remoteCompletedTreatments =
          Map<String, Map<String, dynamic>>.from(userData[_completedTreatmentsFirebaseKey]).map(
        (key, value) => MapEntry(
          key,
          Map<String, int>.from(
            value.map(
              (key, value) => MapEntry<String, int>(key, value),
            ),
          ),
        ),
      );

      /// The logic here is that a treatment can be completed but it cannot be un-completed (we don't remove from the list).
      completedTreatments.forEach((key, value) {
        if (!remoteCompletedTreatments.containsKey(key)) {
          remoteCompletedTreatments[key] = value;
        } else {
          remoteCompletedTreatments[key].addAll(completedTreatments[key]);
        }
      });

      await userDataQuery.reference.updateData(
        {_completedTreatmentsFirebaseKey: remoteCompletedTreatments.map((key, value) => MapEntry(key, value))},
      );
    }
  }

  Future<Map<String, int>> getLastOpenedTreatments() => checkExceptions(_getLastOpenedTreatments());

  Future<Map<String, int>> _getLastOpenedTreatments() async {
    User user = await getUser();
    if (user == null) {
      return Map<String, int>();
    }

    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return Map<String, int>();
    }

    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);
    if (userData[_lastOpenedTreatmentsDayFirebaseKey] == null) {
      return Map<String, int>();
    }

    return Map<String, int>.from(userData[_lastOpenedTreatmentsDayFirebaseKey]);
  }

  Future<Null> saveLastOpenedTreatments(Map<String, int> lastOpenedTreatments) =>
      checkExceptions(_saveLastOpenedTreatments(lastOpenedTreatments));

  Future<Null> _saveLastOpenedTreatments(Map<String, int> lastOpenedTreatments) async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return null;
    }

    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);

    if (!userData.containsKey(_lastOpenedTreatmentsDayFirebaseKey)) {
      userData.addAll({_lastOpenedTreatmentsDayFirebaseKey: lastOpenedTreatments});
      await userDataQuery.reference.setData(userData);
    } else {
      await userDataQuery.reference.updateData({_lastOpenedTreatmentsDayFirebaseKey: lastOpenedTreatments});
    }
  }

  Future<Mood> fetchLastMood() async {
    List<MoodData> moodData = await fetchUserMoodData();
    moodData?.sort((m1, m2) => m1.date.compareTo(m2.date));
    return (moodData != null && moodData.length > 0) ? moodData.last.mood : null;
  }

  Future<List<MoodData>> fetchUserMoodData() async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      _cache.userMoodData = null;
      return null;
    }
    List<dynamic> moodTracking = userDataQuery.data[_moodTrackingV2FirebaseKey];
    if (isEmptyOrNull(moodTracking)) {
      _cache.userMoodData = null;
      return null;
    }
    List<MoodData> moodDatas = moodTracking.map(
      (data) {
        int value = data["mood"];
        if (value == null) {
          return null;
        } else if (value > 5) {
          value = 5;
        } else if (value < -5) {
          value = -5;
        }
        MoodData moodData = MoodData(
          mood: Moods().moods.firstWhere((mood) => mood.value == value, orElse: () => null),
          date: DateTime.fromMillisecondsSinceEpoch(data["timestamp"]),
          feelings: List<String>.from(data["feelings"] ?? []),
          factors: List<String>.from(data["factors"] ?? []),
        );
        if (moodData.mood == null || !moodData.mood.isValid) {
          return null;
        }
        return moodData;
      },
    ).toList()
      ..removeWhere(isNull);
    _cache.userMoodData = moodDatas;
    return moodDatas;
  }

  Future<void> sendMoodTracking({int moodValue, List<String> feelings, List<String> factors}) async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return null;
    }
    Map<String, dynamic> userData = fixFirestoreMapType(userDataQuery.data);

    Map<String, dynamic> dataToSend = {
      if (moodValue != null) "mood": moodValue,
      if (feelings != null) "feelings": feelings,
      if (factors != null) "factors": factors,
      "timestamp": timestamp,
    };

    if (!userData.containsKey(_moodTrackingV2FirebaseKey)) {
      userData.addAll({
        _moodTrackingV2FirebaseKey: [dataToSend]
      });
      return await userDataQuery.reference.setData(userData);
    } else {
      List<Map<String, dynamic>> moodTracking = List<Map<String, dynamic>>.from(userData[_moodTrackingV2FirebaseKey]);
      moodTracking.add(dataToSend);
      return await userDataQuery.reference.updateData({_moodTrackingV2FirebaseKey: moodTracking});
    }
  }

  Future<void> savePillcastCompletedTrack(String trackUid, double percentagePlayed) async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return null;
    }

    Map<String, dynamic> dataToSend = {
      "timestamp": timestamp,
      "track_uid": trackUid,
      "percentage_played": percentagePlayed,
    };

    await userDataQuery.reference.collection(_pillcastCollectionFirebaseKey).document().setData(dataToSend);
  }

  Future<List<String>> loadPillcastCompletedTrackUids() async {
    User user = await getUser();
    DocumentSnapshot userDataQuery = await _fetchUserData(user);
    if (userDataQuery == null) {
      return null;
    }

    QuerySnapshot dataQuery = await userDataQuery.reference.collection(_pillcastCollectionFirebaseKey).getDocuments();
    return dataQuery.documents.map<String>((doc) => doc.data["track_uid"]).toList();
  }

  String getRecommendedTreatmentType() {
    if (_cache.recommendedTreatmentType == null) {
      try {
        List<Treatment> allTreatments =
            _cache.treatments.values.reduce((mergedLists, list) => List<Treatment>.from(mergedLists)..addAll(list));
        int index = Random().nextInt(allTreatments.length);
        _cache.recommendedTreatmentType = allTreatments[index].type;
      } catch (error) {
        print(error);
      }
    }
    return _cache.recommendedTreatmentType;
  }

  Future<void> sendTreatmentTrackingData(TreatmentTrackingData treatmentTrackingData) async {
    User user = await getUser();
    await _api.sendUserTreatmentTrackingData(treatmentTrackingData.cloneWith(
      userUid: user.uid,
      timestamp: timestamp,
    ));
  }
}
