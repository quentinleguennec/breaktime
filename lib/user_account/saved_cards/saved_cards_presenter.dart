import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class SavedCardsPresenter {
  final SavedCardsPresenterView _view;
  UserService _userService;
  MemoryCache _cache;

  SavedCardsPresenter(this._view) {
    _userService = Injector().userService;
    _cache = Injector().cache;
    assert(_view != null);
  }

  void loadSavedCards() {
    if (_cache.savedCards.isEmpty) {
      _userService.fetchSavedCards().then((savedCards) {
        _cache.savedCards = savedCards;
        _view.onSavedCardsLoaded(savedCards);
      }).catchError((error) => onError(error));
    } else {
      _view.onSavedCardsLoaded(_cache.savedCards);
    }
  }

  void onError(e) {
    _view
      ..stopProgress()
      ..showError(e)
      ..onSavedCardsLoaded(_cache.savedCards);
  }
}

abstract class SavedCardsPresenterView implements BasePresenterView {
  void onSavedCardsLoaded(List<DataCard> savedCards);
}
