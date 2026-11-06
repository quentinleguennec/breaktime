import 'package:aebeze/app.dart';
import 'package:aebeze/phq9/phq9_page.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/user_account/emergency_contacts_page.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class PHQ9PopupPresenter {
  TrackingService _trackingService;
  PHQ9PopupPresenterView _view;

  PHQ9PopupPresenter(this._view) {
    assert(_view != null);
    _trackingService = Injector().trackingService;
  }

  pushPHQ9() {
    _trackingService.phq9Open();
    _view.pop();
    if (App.isDayBreak) {
      _view.push(EmergencyContactsPage(isPrivacyPage: false));
    } else {
      _view..push(PHQ9Page());
    }
  }
}

abstract class PHQ9PopupPresenterView implements BasePresenterView {}
