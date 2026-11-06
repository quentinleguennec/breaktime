import 'package:aebeze/services/model.dart';

class MemoryCache {
  List<DataCard> _savedCards = List<DataCard>();
  Map<String, List<Treatment>> _treatments = Map<String, List<Treatment>>();
  Map<String, Map<String, int>> _userCompletedTreatments = Map<String, Map<String, int>>();
  Map<String, int> _userLastOpenedTreatments = Map<String, int>();
  Set<String> _userPillcastCompletedTracksUids = Set<String>();
  List<ActiveIngredient> _activeIngredients = List<ActiveIngredient>.unmodifiable([]);
  List<SupportingScience> _supportingSciences = List<SupportingScience>.unmodifiable([]);
  String recommendedTreatmentType;
  List<MoodData> userMoodData;

  /// Unmodifiable.
  Map<String, List<Treatment>> get treatments => _treatments;

  /// Unmodifiable.
  List<ActiveIngredient> get activeIngredients => _activeIngredients;

  /// Unmodifiable.
  List<SupportingScience> get supportingSciences => _supportingSciences;

  Map<String, Map<String, int>> get userCompletedTreatments => _userCompletedTreatments;

  Map<String, int> get userLastOpenedTreatments => _userLastOpenedTreatments;

  Set<String> get userPillcastCompletedTracksUids => _userPillcastCompletedTracksUids;

  List<DataCard> get savedCards => _savedCards;

  set savedCards(List<DataCard> value) => _savedCards = value ?? List<DataCard>();

  set treatments(Map<String, List<Treatment>> value) {
    Map<String, List<Treatment>> unmodifiableMap =
        value.map((type, treatments) => MapEntry(type, List.unmodifiable(treatments)));
    unmodifiableMap = Map.unmodifiable(unmodifiableMap);
    _treatments = unmodifiableMap ?? Map.unmodifiable(Map<String, List<Treatment>>());
  }

  set userCompletedTreatments(Map<String, Map<String, int>> value) =>
      _userCompletedTreatments = value ?? Map<String, Map<String, int>>();

  set userLastOpenedTreatments(Map<String, int> value) => _userLastOpenedTreatments = value ?? Map<String, int>();

  set userPillcastCompletedTracksUids(Set<String> value) => _userPillcastCompletedTracksUids = value ?? Set<String>();

  set activeIngredients(List<ActiveIngredient> value) {
    value = value ?? List<ActiveIngredient>();
    _activeIngredients = List.unmodifiable(value);
  }

  set supportingSciences(List<SupportingScience> value) {
    value = value ?? List<SupportingScience>();
    _supportingSciences = List.unmodifiable(value);
  }

  void clearUserData() {
    userMoodData = null;
    userCompletedTreatments = null;
    userLastOpenedTreatments = null;
    savedCards = null;
  }

  void addUserMoodData(MoodData moodData) {
    if (userMoodData == null) {
      userMoodData = List<MoodData>();
    }
    userMoodData.add(moodData);
  }

  Mood get lastCachedMood {
    userMoodData?.sort((m1, m2) => m1.date.compareTo(m2.date));
    return (userMoodData != null && userMoodData.length > 0) ? userMoodData.last.mood : null;
  }

  bool addUserPillcastTrackCompletedUid(String trackUid) => _userPillcastCompletedTracksUids.add(trackUid);
}
