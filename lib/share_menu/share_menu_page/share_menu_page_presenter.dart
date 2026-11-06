import 'dart:async';

import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:share/share.dart';

class ShareMenuPagePresenter {
  final ShareMenuPagePresenterView _view;
  TrackingService _trackingService;

  ShareMenuPagePresenter(this._view) {
    assert(_view != null);
    _trackingService = Injector().trackingService;
  }

  Future<List<String>> getAvailableSharingApps() async {
    List<String> availableApps = List<String>();
    availableApps.addAll(await Share.listKnownAvailableSharingApps());
    if (await FacebookLogin.canShareWithFacebook()) {
      availableApps.add("facebook");
    }
    if (await FacebookLogin.canShareWithMessenger()) {
      availableApps.add("messenger");
    }
    return availableApps;
  }

  void onShare(String shareType, String cardUid) => _trackingService.share(
        shareType,
        cardUid,
      );
}

abstract class ShareMenuPagePresenterView implements BasePresenterView {}
