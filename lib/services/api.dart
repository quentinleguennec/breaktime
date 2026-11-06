import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';

class Api {
  static String get cdnHost => '${App.projectId}.firebaseapp.com';

  static String get host => 'us-central1-${App.projectId}.cloudfunctions.net';

  static final Uri defaultBaseUri = Uri(
    scheme: 'https',
    host: host,
  );

  static final Uri defaultCdnBaseUri = Uri(
    scheme: 'https',
    host: cdnHost,
  );

  Future<List<ActiveIngredient>> fetchActiveIngredients() => checkExceptions(_fetchActiveIngredients());

  Future<List<ActiveIngredient>> _fetchActiveIngredients() async {
    Stream<FileInfo> file = DefaultCacheManager().getFile(
      defaultCdnBaseUri.replace(path: "chemicals").toString(),
      headers: {"content-type": "application/json"},
    );
    if (file == null) {
      return List<ActiveIngredient>();
    }
    String jsonString = await (await file.first).file.readAsString();
    return ActiveIngredients.fromJson(json.decode(jsonString) as Map<String, dynamic>, node: "results")
        .activeIngredients;
  }

  Future<List<SupportingScience>> fetchSupportingSciences() => checkExceptions(_fetchSupportingSciences());

  Future<List<SupportingScience>> _fetchSupportingSciences() async {
    Stream<FileInfo> file = DefaultCacheManager().getFile(
      defaultCdnBaseUri.replace(path: "supporting_sciences").toString(),
      headers: {"content-type": "application/json"},
    );
    if (file == null) {
      return List<SupportingScience>();
    }
    String jsonString = await (await file.first).file.readAsString();
    return SupportingSciences.fromJson(json.decode(jsonString) as Map<String, dynamic>, node: "results")
        .supportingSciences;
  }

  Future<List<DataCard>> fetchDraftCards() => checkExceptions(_fetchDraftCards());

  Future<List<DataCard>> _fetchDraftCards() async {
    Map<String, String> header = await _getAuthorizationHeader();
    Map<String, dynamic> json = await _get(defaultBaseUri.replace(path: "testing_cards"), headers: header);
    return DataCards.fromJson(json).cards;
  }

  Future<List<DataCard>> fetchPublishedCards(List<String> cardsUids) =>
      checkExceptions(_fetchPublishedCards(cardsUids));

  Future<List<DataCard>> _fetchPublishedCards(List<String> cardsUids) async {
    Map<String, String> headers = Map<String, String>();
    headers.addAll({"content-type": "application/json"});
    String body = """
    {
      "uids": [\"${cardsUids.join("\",\"")}\"]
    }
    """;
    Map<String, dynamic> json =
        await _post(defaultCdnBaseUri.replace(path: "published_cards"), headers: headers, body: body);
    List<DataCard> savedCards = DataCards.fromJson(json).cards;
    savedCards.removeWhere((card) => card.isErrorCard());
    return savedCards;
  }

  Future<DataCard> fetchPublishedCard(String cardUid) => checkExceptions(_fetchPublishedCard(cardUid));

  Future<DataCard> _fetchPublishedCard(String cardUid) async {
    Map<String, dynamic> json = await _get(defaultCdnBaseUri.replace(path: "published_card/$cardUid"));
    List<DataCard> cards = DataCards.fromJson(json).cards;
    return cards.isEmpty ? null : cards.first;
  }

  Future<List<Treatment>> fetchDraftTreatments() => checkExceptions(_fetchDraftTreatments());

  Future<List<Treatment>> _fetchDraftTreatments() async {
    Stream<FileInfo> file = DefaultCacheManager().getFile(
      defaultBaseUri.replace(path: "testing_treatments").toString(),
      headers: {"content-type": "application/json"},
    );
    if (file == null) {
      return List<Treatment>();
    }
    String jsonString = await (await file.first).file.readAsString();
    return Treatments.fromJson(json.decode(jsonString) as Map<String, dynamic>, node: "results").treatments;
  }

  Future<List<Treatment>> fetchPublishedTreatments() => checkExceptions(_fetchPublishedTreatments());

  Future<List<Treatment>> _fetchPublishedTreatments() async {
    Stream<FileInfo> file = DefaultCacheManager().getFile(
      defaultCdnBaseUri.replace(path: "treatments").toString(),
      headers: {"content-type": "application/json"},
    );
    if (file == null) {
      return List<Treatment>();
    }
    String jsonString = await (await file.first).file.readAsString();
    return Treatments.fromJson(json.decode(jsonString) as Map<String, dynamic>, node: "results").treatments;
  }

  Future<bool> isAppVersionValid() => checkExceptions(_isAppVersionValid());

  Future<bool> _isAppVersionValid() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, dynamic> json = await _get(defaultCdnBaseUri.replace(path: "app_version/${packageInfo.buildNumber}"));
    return json["supported"];
  }

  Future<String> fetchRecommendedTreatmentType(String userId) =>
      checkExceptions(_fetchRecommendedTreatmentType(userId)).catchError((_) => null);

  Future<String> _fetchRecommendedTreatmentType(String userId) async {
    Map<String, String> headers = await _getAuthorizationHeader();
    Map<String, dynamic> json =
        await _get(defaultBaseUri.replace(path: "suggested_treatments/$userId"), headers: headers);
    if (json["type"] != "none") {
      return json["type"];
    }
    return null;
  }

  Future<void> sendUserTreatmentTrackingData(TreatmentTrackingData treatmentTrackingData) async {
    Map<String, String> headers = await _getAuthorizationHeader();
    headers.addAll({"content-type": "application/json"});
    await _post(defaultBaseUri.replace(path: "treatment_tracking"),
        headers: headers, body: treatmentTrackingData.asJsonBody());
  }

  Future<Map<String, dynamic>> _post(Uri uri, {Map<String, String> headers, dynamic body}) async {
    if (App.httpLogsOn) print("- _post : $uri");
    if (headers == null) {
      headers = {};
    }
    headers.addAll({"language": App.locale.languageCode});
    if (App.httpLogsOn) headers.forEach((key, value) => print("- Header : $key: $value"));
    if (App.httpLogsOn) body != null ? print("- body : $body") : print("- body is null");
    final Response response = await post(uri, headers: headers, body: body);
    if (App.httpLogsOn) print('- Response status: ${response.statusCode}');
    if (App.httpLogsOn) print(response.body);
    if (response.body == "Unauthorized") {
      throw ApiException("error_permission_denied");
    }
    if (response.statusCode != 200) {
      throw ApiException("error_server_content");
    }
    return (json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _get(Uri uri, {Map<String, String> headers, Map<String, String> queryParameters}) async {
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    if (App.httpLogsOn) print("- _get : $uri");
    if (headers == null) {
      headers = {};
    }
    headers.addAll({"language": App.locale.languageCode, "version": "2"});
    if (App.httpLogsOn) headers.forEach((key, value) => print("- Header : $key: $value"));
    final Response response = await get(uri, headers: headers);
    if (App.httpLogsOn) print('- Response status: ${response.statusCode}');
    if (App.httpLogsOn) print("response.body = " + response.body);
    if (response.body == "Unauthorized") {
      throw ApiException("error_permission_denied");
    }
    if (response.statusCode != 200) {
      throw ApiException("error_server_content");
    }
    return (json.decode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, String>> _getAuthorizationHeader() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    String idToken = (await firebaseUser.getIdToken()).token;
    return {"authorization": "Bearer $idToken"};
  }

  Future<bool> checkInternetConnectivity() async {
    try {
      final List<InternetAddress> result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}

class ApiException implements Exception {
  final String message;
  final bool localized;

  ApiException(this.message, {this.localized = true});

  String getLocalizedMessage(BuildContext context) => localized ? localize(context, message) : message;

  bool isNetworkException() => "error_network_not_available".indexOf(message) != -1;

  bool isServerException() => "error_server_content".indexOf(message) != -1;

  bool isUserSignInCancel() => "error_user_cancel_signin".indexOf(message) != -1;

  bool isPermissionException() => "error_permission_denied".indexOf(message) != -1;

  bool isUnknownException() => "unknown_error".indexOf(message) != -1;

  @override
  String toString() => 'ApiException{message: $message, localized: $localized}';
}

Future<T> checkExceptions<T>(Future<T> future) {
  TrackingService trackingService = Injector().trackingService;
  return future.catchError(
    (dynamic e, StackTrace t) {
      print("Re-thrown exception : $e\nTrace:\n$t");
      trackingService?.silentException(e);
      throw e;
    },
    test: (Object e) => e is ApiException,
  ).catchError(
    (dynamic e, StackTrace t) {
      print("Possible network exception : $e\nTrace:\n$t");
      trackingService?.silentException(e);
      throw ApiException("error_network_not_available");
    },
    test: (Object e) =>
        e is SocketException ||
        ((e is PlatformException && e.message != null && e.message.toUpperCase().contains("NETWORK")) ||
            (e is PlatformException && e.details != null && e.details.toUpperCase().contains("NETWORK"))),
  ).catchError(
    (dynamic e, StackTrace t) {
      print("Possible platform exception : $e\nTrace:\n$t");
      trackingService?.silentException(e);
      if (e.message != null && e.message.toUpperCase().contains("PERMISSION_DENIED")) {
        throw ApiException("error_permission_denied");
      }
      String message = e.message;
      if (e.details != null && e.details.toString().length > e.message.length) {
        message = e.details;
      }
      throw ApiException(message, localized: false);
    },
    test: (Object e) => e is PlatformException,
  ).catchError(
    (dynamic e, StackTrace t) {
      print("Possible server exception : $e\nTrace:\n$t");
      trackingService?.silentException(e);
      throw ApiException("error_server_content");
    },
    test: (Object e) => e is FormatException,
  ).catchError(
    (dynamic e, StackTrace t) {
      print("Unclassified exception : $e\nTrace:\n$t");
      trackingService?.silentException(e);
      throw ApiException("unknown_error");
    },
    test: (Object e) => !(e is ApiException) && e is Exception,
  ).catchError(
    (dynamic e) {
      print("Unclassified error : $e\nTrace:\n${e.stackTrace}");
      trackingService?.silentException(ApiException(e.stackTrace.toString(), localized: false));
      throw ApiException("unknown_error");
    },
    test: (Object e) => e is Error,
  );
}
