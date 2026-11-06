import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:url_launcher/url_launcher.dart';

class UpsellCardPresenter {
  final UpsellCardPresenterView _view;
  TrackingService _trackingService;

  UpsellCardPresenter(this._view) {
    assert(_view != null);
    _trackingService = Injector().trackingService;
  }

  void openLink(DataCard card) {
    String url = card.upsellData.link;
    if (url.startsWith("www.")) {
      url = "https://" + url;
    }
    launch(url);
    _trackingService.upsellButtonPressed(card.uid);
  }
}

abstract class UpsellCardPresenterView implements BasePresenterView {}
