import 'dart:async';

import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class DeepLinkContentLoaderPagePresenter {
  final DeepLinkContentLoaderPagePresenterView _view;
  UserService _userService;
  Api _api;

  DeepLinkContentLoaderPagePresenter(this._view) {
    _userService = Injector().userService;
    _api = Injector().api;
    assert(_view != null);
  }

  Future<bool> isUserLoggedIn() => _userService.isUserLoggedIn();

  Future<DataCard> fetchCard(String cardUid) => _api.fetchPublishedCard(cardUid);
}

abstract class DeepLinkContentLoaderPagePresenterView implements BasePresenterView {}
