import 'package:aebeze/authentication/authentication_presenter.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class SignUpPresenter extends AuthenticationPresenter {
  final SignUpPresenterView _view;
  UserService _userService;
  TrackingService _trackingService;
  MemoryCache _cache;

  SignUpPresenter(this._view) : super(_view) {
    _userService = Injector().userService;
    _trackingService = Injector().trackingService;
    _cache = Injector().cache;
    assert(_view != null);
    _trackingService.signUpPageOpen();
  }

  void logInWithFacebook() {
    _view.startProgress();
    _trackingService.facebookLogin();
    _userService.loginWithFacebook().then((_) => onSuccess()).catchError((dynamic error) => onError(error));
  }

  void loadSavedCards() {
    if (_cache.savedCards.isEmpty) {
      _userService.fetchSavedCards().then((savedCards) {
        _cache.savedCards = savedCards;
      }).catchError((error) => onError(error));
    }
  }

  void signUpWithEmail(
    String email,
    String password, {
    String airforceBase,
    String airforceUnitSquadron,
    String airforceSpecialtyCode,
    String gender,
    String ageRange,
    String airforceShift,
  }) {
    _view.startProgress();
    _trackingService.signUp();
    _userService
        .signUpNewUser(
          email,
          password,
          airforceBase: airforceBase,
          airforceUnitSquadron: airforceUnitSquadron,
          airforceSpecialtyCode: airforceSpecialtyCode,
          gender: gender,
          ageRange: ageRange,
          airforceShift: airforceShift,
        )
        .then((_) => onSuccess())
        .catchError((error) => onError(error));
  }

  @override
  void onSuccess() {
    super.onSuccess();
    loadSavedCards();
    _trackingService.signUpSuccess();
    _view.onSignUpSuccess();
  }

  @override
  void onError(dynamic e) {
    _trackingService.signUpFailure();
    super.onError(e);
  }
}

abstract class SignUpPresenterView implements BasePresenterView, AuthenticationPresenterView {
  void onSignUpSuccess();
}
