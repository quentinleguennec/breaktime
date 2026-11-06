import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class EndCardPresenter {
  final EndCardPresenterView _view;
  MemoryCache _cache;
  UserService _userService;

  EndCardPresenter(this._view) {
    assert(_view != null);
    _cache = Injector().cache;
    _userService = Injector().userService;
  }

  void updateCompletedTreatments(Treatment treatment) {
    if (_cache.userCompletedTreatments.containsKey(treatment.type) &&
        _cache.userCompletedTreatments[treatment.type].containsKey(treatment.day.toString())) {
      /// Nothing to save.
      return;
    }

    if (!_cache.userCompletedTreatments.containsKey(treatment.type)) {
      _cache.userCompletedTreatments[treatment.type] = Map<String, int>();
    }
    _cache.userCompletedTreatments[treatment.type]
        .addAll({treatment.day.toString(): DateTime.now().millisecondsSinceEpoch});
    _userService.saveCompletedTreatments(_cache.userCompletedTreatments);
  }
}

abstract class EndCardPresenterView implements BasePresenterView {}
