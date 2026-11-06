import 'dart:async';

import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class MoodSelectorBundlePresenter {
  final MoodSelectorBundlePresenterView _view;
  UserService _userService;

  MoodSelectorBundlePresenter(this._view) {
    assert(_view != null);
    _userService = Injector().userService;
  }

  Future<bool> checkIfNeedToShowAppStarMoodSelector() => _userService.checkIfNeedToShowAppStartMoodSelector();

  Future<void> updateAppStartMoodSelectorLastOpenDate() => _userService.updateAppStartMoodSelectorLastOpenDate();

  Future<void> showPHQ9IfNeeded(int moodValue) async {
    bool needsPHQ9 = await _userService.checkIfNeedPHQ9(moodValue);
    if (needsPHQ9) {
      _view.pushPHQ9PopupPage();
    }
  }

  Future<void> sendUserData(MoodSelectorBundleData userData) async {
    if (userData != null && !userData.isEmpty) {
      await _userService.sendMoodTracking(
        moodValue: userData.moodValue,
        feelings: userData.moodFeelings,
        factors: userData.moodFactors,
      );
    }
  }
}

abstract class MoodSelectorBundlePresenterView implements BasePresenterView {}
