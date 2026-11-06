import 'dart:collection';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/end_card/end_card.dart';
import 'package:aebeze/cards/start_card/start_card.dart';
import 'package:aebeze/events/update_dashboard_event.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/share_menu/share_menu_page/share_menu_page.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';

class CardsPagePresenter {
  final HashSet<String> completedCard = HashSet<String>();
  CardsPagePresenterView _view;
  TrackingService _trackingService;
  List<DataCard> wrappedCards;
  EventBus _eventBus;
  UserService _userService;
  MemoryCache _cache;
  bool isUserLoggedIn = false;

  int get completedCardsCount => completedCard.length;

  CardsPagePresenter(this._view) {
    _trackingService = Injector().trackingService;
    _eventBus = Injector().eventBus;
    _userService = Injector().userService;
    _cache = Injector().cache;
    _userService.isUserLoggedIn().then((isLoggedIn) => isUserLoggedIn = isLoggedIn);
    assert(_view != null);
  }

  void buildWrappedCards(Treatment treatment, BuildContext context) {
    if (treatment.isSpecial) {
      this.wrappedCards = treatment.cards.first.isSupported() ? treatment.cards : [errorCard];
    } else {
      wrappedCards = [
        StartCard.getCard(treatment, context),
        ...treatment.cards,
        EndCard.getCard(treatment, context),
      ]..retainWhere((card) => card.isSupported());
    }
  }

  void onCardStarted(DataCard card) => _trackingService.viewCard(card);

  void onCardCompleted(DataCard card) {
    _trackingService.cardCompleted(card);
    completedCard.add(card.uid);
  }

  void updateDashboard() {
    _eventBus.fire(UpdateDashboardEvent());
  }

  void sendTreatmentCompletedData(TreatmentTrackingData treatmentTrackingData) async {
    await _userService.sendTreatmentTrackingData(treatmentTrackingData);
  }

  bool isCardSaved(DataCard card) => _cache.savedCards.contains(card);

  void saveCard(DataCard card) {
    _userService.saveCard(card);
    _trackingService.saveCard(card);
  }

  void removeSavedCard(DataCard card) => _userService.removeSavedCard(card);

  void saveOrRemoveCard(DataCard card) async {
    if (isUserLoggedIn == null || card.isErrorCard() || card.isStartCard() || card.isEndCard()) return;

    if (isUserLoggedIn) {
      isCardSaved(card) ? removeSavedCard(card) : saveCard(card);
    } else {
      await _view.pushAuthenticationPage();
      isUserLoggedIn = await _userService.isUserLoggedIn();
    }
  }

  void openSharePage(DataCard card) {
    if (card.isStartCard() || card.isEndCard() || card.isErrorCard()) {
      return;
    }
    _view.push(SharePage(isCardUrl: true, cardUid: card.uid));
  }
}

abstract class CardsPagePresenterView implements BasePresenterView {}
