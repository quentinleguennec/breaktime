import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PHQ9ResultCardPresenter {
  PHQ9ResultCardPresenterView _view;
  TrackingService _trackingService;

  PHQ9ResultCardPresenter(this._view) {
    _trackingService = Injector().trackingService;
    assert(_view != null);
  }

  void openSMSApp() {
    _trackingService.emergencyContactPressed();
    const String url = 'sms:741741?body=HOME';
    canLaunch(url).then((canLaunch) {
      if (canLaunch) {
        HapticFeedback.mediumImpact();
        launch(url);
      }
    });
  }

  void trackCompletion(bool wasWholeTest) => _trackingService.phq9Completed(wasWholeTest);
}

abstract class PHQ9ResultCardPresenterView implements BasePresenterView {}
