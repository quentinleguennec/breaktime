import 'package:aebeze/authentication/authentication_presenter.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class LogInPresenter extends AuthenticationPresenter {
  final LogInPresenterView _view;
  UserService _userService;
  TrackingService _trackingService;
  MemoryCache _cache;

  LogInPresenter(this._view) : super(_view) {
    _userService = Injector().userService;
    _trackingService = Injector().trackingService;
    _cache = Injector().cache;
    assert(_view != null);
  }

  void logInWithFacebook() {
    _view.startProgress();
    _trackingService.facebookLogin();
    _userService.loginWithFacebook().then((_) => onSuccess()).catchError((dynamic error) => onError(error));
  }

  void logInWithEmail(String username, String password) {
    _view.startProgress();
    _trackingService.login();
    _userService.login(username, password).then((_) => onSuccess()).catchError((dynamic error) => onError(error));
  }

  void loadSavedCards() {
    if (_cache.savedCards.isEmpty) {
      _userService.fetchSavedCards().then((savedCards) {
        _cache.savedCards = savedCards;
      }).catchError((error) => onError(error));
    }
  }

  @override
  void onSuccess() {
    super.onSuccess();
    loadSavedCards();
    _view.onLogInSuccess();
  }
}

abstract class LogInPresenterView implements BasePresenterView, AuthenticationPresenterView {
  void onLogInSuccess();
}
