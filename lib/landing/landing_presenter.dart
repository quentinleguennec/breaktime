import 'dart:async';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:launch_review/launch_review.dart';

class LandingPagePresenter {
  final LandingPresenterView _view;
  UserService _userService;
  Api _api;
  bool isShowingAppUpdateDialog = false;
  bool isCheckingConnectivity = false;

  LandingPagePresenter(this._view) {
    _userService = Injector().userService;
    _api = Injector().api;
    assert(_view != null);
    // we need to create an anonymous user before the onboarding to be able to send mood tracking data
    _userService.getUser();
  }

  Future<void> checkInternetConnectivity() async {
    if (isCheckingConnectivity) {
      return;
    }
    isCheckingConnectivity = true;

    bool isConnected = false;
    while (!isConnected) {
      isConnected = await _api.checkInternetConnectivity();
      if (!isConnected) {
        await _view.showNetworkAlertDialog();
      }
    }
    isCheckingConnectivity = false;
  }

  Future<bool> showDialogIfAppNeedsUpdate() async {
    if (isShowingAppUpdateDialog) {
      return true;
    }
    bool needsUpdate = !(await _api.isAppVersionValid().catchError(
      (error) async {
        if (error is ApiException && error.isNetworkException()) {
          await checkInternetConnectivity();
          return showDialogIfAppNeedsUpdate();
        } else {
          _view.showError(error);
          return true;
        }
      },
    ));
    if (!needsUpdate) {
      return false;
    } else {
      bool dialogWasDismissed = true;
      while (dialogWasDismissed) {
        isShowingAppUpdateDialog = true;
        await _view.showAlertDialog(
          "alert_app_needs_update_error_title",
          "alert_app_needs_update_error_msg",
          "alert_app_needs_update_error_action",
          onActionButtonPressed: () {
            isShowingAppUpdateDialog = false;
            dialogWasDismissed = false;
          },
        );
        if (!dialogWasDismissed) {
          LaunchReview.launch(androidAppId: aebezeAndroidAppId, iOSAppId: aebezeIosAppId);
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> isUserLoggedIn() => _userService.isUserLoggedIn();

  Future<DataCard> fetchCard(String cardUid) =>
      _api.fetchPublishedCard(cardUid).catchError((dynamic error) => onError(error));

  void onError(dynamic e) {
    if (App.inDebugMode) print("Error: ${e.message}");
  }
}

abstract class LandingPresenterView implements BasePresenterView {}
