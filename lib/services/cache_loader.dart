import 'package:aebeze/app.dart';
import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class CacheLoader {
  MemoryCache _cache = Injector().cache;
  Api _api = Injector().api;
  UserService _userService = Injector().userService;

  void prepare(
    VoidCallback onReady, {
    List<Future<void>> futuresToExecuteInParallel,
    Function onError = print,
  }) async {
    try {
      final futures = [
        _loadSavedCards(),
        _loadTreatments(),
        _loadActiveIngredients(),
        _loadSupportingSciences(),
        _loadCompletedTreatments(),
        _loadLastOpenedTreatments(),
        _loadRecommendedTreatmentType(),
      ];
      if (futuresToExecuteInParallel != null) futures.addAll(futuresToExecuteInParallel);
      await Future.wait(futures);
      onReady();
    } catch (e) {
      onError(e);
    }
  }

  Future<void> _loadTreatments() async {
    if (_cache.treatments == null || _cache.treatments.isEmpty) {
      final treatments = await _api.fetchPublishedTreatments();
      if (treatments != null) {
        Map<String, List<Treatment>> groupedTreatments = groupBy(treatments, (Treatment treatment) => treatment.type);
        groupedTreatments.forEach((_, list) => list.sort((t1, t2) => t1.day.compareTo(t2.day)));
        _cache.treatments = groupedTreatments;
      }
    }
    if (App.cacheLogsOn) print("- treatments loaded");
  }

  Future<void> _loadSavedCards() async {
    try {
      if (_cache.savedCards == null || _cache.savedCards.isEmpty) {
        final savedCards = await _userService.fetchSavedCards();
        if (savedCards != null) {
          _cache.savedCards = savedCards;
        }
      }
    } catch (e) {
      print(e);
    }
    if (App.cacheLogsOn) print("- saved cards loaded");
  }

  Future<void> _loadCompletedTreatments() async {
    if (_cache.userCompletedTreatments == null || _cache.userCompletedTreatments.isEmpty) {
      final completedTreatments = await _userService.getCompletedTreatments();
      if (completedTreatments != null) {
        _cache.userCompletedTreatments = completedTreatments;
      }
    }
    if (App.cacheLogsOn) print("- completed treatments loaded");
  }

  Future<void> _loadLastOpenedTreatments() async {
    if (_cache.userLastOpenedTreatments == null || _cache.userLastOpenedTreatments.isEmpty) {
      final userLastOpenedTreatments = await _userService.getLastOpenedTreatments();
      if (userLastOpenedTreatments != null) {
        _cache.userLastOpenedTreatments = userLastOpenedTreatments;
      }
    }
    if (App.cacheLogsOn) print("- last opened treatments loaded");
  }

  Future<void> _loadSupportingSciences() async {
    if (_cache.supportingSciences == null || _cache.supportingSciences.isEmpty) {
      final supportingSciences = await _api.fetchSupportingSciences();
      if (supportingSciences != null) {
        _cache.supportingSciences = supportingSciences;
      }
    }
    if (App.cacheLogsOn) print("- supporting sciences loaded");
  }

  Future<void> _loadActiveIngredients() async {
    if (_cache.activeIngredients == null || _cache.activeIngredients.isEmpty) {
      final activeIngredients = await _api.fetchActiveIngredients();
      if (activeIngredients != null) {
        _cache.activeIngredients = activeIngredients;
      }
    }
    if (App.cacheLogsOn) print("- active ingredients loaded");
  }

  Future<void> _loadRecommendedTreatmentType() async {
    try {
      if (_cache.recommendedTreatmentType == null) {
        User user = await _userService.getUser();
        _cache.recommendedTreatmentType = await _api.fetchRecommendedTreatmentType(user.uid);
      }
    } catch (e) {
      print(e);
    }
    if (App.cacheLogsOn) print("- recommended treatment type loaded");
  }
}
