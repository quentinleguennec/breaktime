import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class StartCardPresenter {
  final StartCardPresenterView _view;
  MemoryCache _cache;
  UserService _userService;

  Map<String, Map<String, int>> get completedTreatments => _cache.userCompletedTreatments;

  StartCardPresenter(this._view) {
    assert(_view != null);
    _cache = Injector().cache;
    _userService = Injector().userService;
  }

  void updateUserLastOpenedTreatments(Treatment treatment) {
    _cache.userLastOpenedTreatments[treatment.type] = treatment.day;
    _userService.saveLastOpenedTreatments(_cache.userLastOpenedTreatments);
  }

  List<Treatment> getTreatmentsOfType(String type) => _cache.treatments[type];
}

abstract class StartCardPresenterView implements BasePresenterView {}
