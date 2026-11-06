import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPagePresenter {
  EmergencyContactsPagePresenterView _view;
  TrackingService _trackingService;

  EmergencyContactsPagePresenter(this._view) {
    _trackingService = Injector().trackingService;
    assert(_view != null);
  }

  void openPhoneApp(String number) {
    _trackingService.emergencyContactPressed();
    final String url = 'tel:$number';
    canLaunch(url).then((canLaunch) {
      if (canLaunch) {
        HapticFeedback.mediumImpact();
        launch(url);
      }
    });
  }
}

abstract class EmergencyContactsPagePresenterView implements BasePresenterView {}
