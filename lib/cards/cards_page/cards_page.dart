import 'dart:math';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/card_overlay_menu_controller.dart';
import 'package:aebeze/cards/cards_page/cards_page_presenter.dart';
import 'package:aebeze/cards/drag_card.dart';
import 'package:aebeze/cards/end_card/end_card.dart';
import 'package:aebeze/cards/error_card.dart';
import 'package:aebeze/cards/messaging_card.dart';
import 'package:aebeze/cards/start_card/start_card.dart';
import 'package:aebeze/cards/story_card.dart';
import 'package:aebeze/cards/upsell_card.dart';
import 'package:aebeze/cards/video_card.dart';
import 'package:aebeze/cards/widgets/custom_page_view.dart';
import 'package:aebeze/cards/wildcard_card.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/buttons/animated_heart_button.dart';
import 'package:aebeze/widgets/buttons/card_timer.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:aebeze/widgets/card_menu.dart';
import 'package:aebeze/widgets/close_treatment_slide_container.dart';
import 'package:aebeze/widgets/slide_gesture_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:screen/screen.dart';
import 'package:slide_container/slide_container.dart';
import 'package:slide_container/slide_container_controller.dart';

class CardsPage extends PopupRoute<Null> {
  final Treatment treatment;
  final bool preventStartCardTransitionAnimation;
  final bool isRecommendedTreatment;
  final VoidCallback onTreatmentCompleted;
  final VoidCallback onNextPressed;

  CardsPage({
    @required this.treatment,
    this.preventStartCardTransitionAnimation = false,
    this.isRecommendedTreatment = false,
    this.onTreatmentCompleted,
    this.onNextPressed,
  }) : super(settings: TrackingService.treatmentPage);

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => false;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // For saved cards or deeplink cards we play a slide in animation.
    if (animation.status == AnimationStatus.forward) {
      if (treatment.isMoodSelector) {
        return FadeTransition(
          child: child,
          opacity: Tween<double>(begin: 0, end: 1).animate(animation),
        );
      }
      if ((treatment.isDeepLinkCard || treatment.isSavedCard)) {
        return SlideTransition(
          child: child,
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
        );
      }
    }
    return child;
  }

  @override
  Widget buildPage(_, __, ___) => CardsPageWidget(
        treatment: treatment,
        preventStartCardTransitionAnimation: preventStartCardTransitionAnimation,
        isRecommendedTreatment: isRecommendedTreatment,
        onTreatmentCompleted: onTreatmentCompleted,
        onNextPressed: onNextPressed,
      );
}

class CardsPageWidget extends StatefulWidget {
  final Treatment treatment;
  final bool preventStartCardTransitionAnimation;
  final bool isRecommendedTreatment;
  final VoidCallback onTreatmentCompleted;
  final VoidCallback onNextPressed;

  CardsPageWidget({
    @required this.treatment,
    this.preventStartCardTransitionAnimation = false,
    this.isRecommendedTreatment = false,
    this.onTreatmentCompleted,
    this.onNextPressed,
  });

  @override
  _CardsPageWidgetState createState() => _CardsPageWidgetState();
}

class _CardsPageWidgetState extends BasePresenter<CardsPageWidget>
    with SingleTickerProviderStateMixin
    implements CardsPagePresenterView {
  final SlideContainerController slideContainerController = SlideContainerController();
  final ValueNotifier<bool> isMenuHiddenNotifier = ValueNotifier<bool>(true);
  final CardOverlayMenuController menuController = CardOverlayMenuController();
  final SwipeUpIconButtonController swipeUpIconButtonController = SwipeUpIconButtonController();
  final AnimatedHeartButtonController heartButtonController = AnimatedHeartButtonController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController floatingButtonsAnimationController;
  PageController pageController;
  CardsPagePresenter presenter;
  bool isCardPlaying = false;
  List<CardTimerController> _cardTimerControllers;
  List<ValueNotifier<CardVisibilityChanged>> _visibilityChangedNotifiers;
  List<PageContext> _pageContexts;
  int pagesViewedCount = 1;
  TreatmentTrackingData treatmentTrackingData;

  DataCard get currentCard => wrappedCards[currentPageIndex];

  bool get isCardUncompleted => cardTimerControllers[currentPageIndex].status != TimerStatus.completed;

  bool get isCardWithoutFloatingButtons =>
      currentCard.isStartCard() || currentCard.isEndCard() || currentCard.isErrorCard();

  List<DataCard> get wrappedCards {
    if (presenter.wrappedCards == null) {
      presenter.buildWrappedCards(widget.treatment, context);
    }
    return presenter.wrappedCards;
  }

  List<ValueNotifier<CardVisibilityChanged>> get visibilityChangedNotifiers {
    if (_visibilityChangedNotifiers == null) {
      _visibilityChangedNotifiers = List<ValueNotifier<CardVisibilityChanged>>(wrappedCards.length);
    }
    return _visibilityChangedNotifiers;
  }

  List<CardTimerController> get cardTimerControllers {
    if (_cardTimerControllers == null) {
      _cardTimerControllers = List<CardTimerController>(wrappedCards.length);
      for (int i = 0; i < wrappedCards.length; ++i) {
        _cardTimerControllers[i] = CardTimerController();
      }
    }
    return _cardTimerControllers;
  }

  int get currentPageIndex {
    if (!pageController.hasClients) {
      return 0;
    }
    try {
      return pageController.page.round();
    } catch (e) {
      // This try/catch shouldn't be needed, it's just a work around for this issue. Remove it when the bug in the framework is fixed.
      // Cf: https://github.com/flutter/flutter/issues/18370
      return 0;
    }
  }

  _CardsPageWidgetState() {
    presenter = CardsPagePresenter(this);
  }

  @override
  void initState() {
    Screen.keepOn(true);
    pageController = PageController(initialPage: 0);
    menuController.addListener(onMenuVisibilityChanged);
    floatingButtonsAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    treatmentTrackingData = TreatmentTrackingData(widget.treatment.uid, widget.isRecommendedTreatment);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isCardWithoutFloatingButtons) {
      floatingButtonsAnimationController.value = 1;
    }
    if (_pageContexts == null) {
      _pageContexts = List<PageContext>.generate(wrappedCards.length, (int index) {
        DataCard card = wrappedCards[index];
        bool hasStartCard = wrappedCards.any((card) => card.isStartCard());
        CardVisibilityChanged cardVisibility =
            index == currentPageIndex ? CardVisibilityChanged.onScreen : CardVisibilityChanged.offScreen;
        if (visibilityChangedNotifiers[index] == null) {
          visibilityChangedNotifiers[index] = ValueNotifier<CardVisibilityChanged>(cardVisibility);
        } else {
          visibilityChangedNotifiers[index].value = cardVisibility;
        }
        return PageContext(
          treatment: widget.treatment,
          card: card,
          onCardStarted: onCardStarted,
          onCardCompleted: () => presenter.onCardCompleted(currentCard),
          cardTimerController: cardTimerControllers[index],
          visibilityChangedNotifier: visibilityChangedNotifiers[index],
          onNextPressed: moveToNextPage,
          slideContainerController: slideContainerController,
          isRecommendedTreatment: widget.isRecommendedTreatment,
          hasStartCard: hasStartCard,
          menuController: menuController,
        );
      }, growable: false);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    Screen.keepOn(false);
    visibilityChangedNotifiers?.forEach((notifier) => notifier?.dispose());
    cardTimerControllers?.forEach((notifier) => notifier?.dispose());
    floatingButtonsAnimationController?.dispose();
    pageController?.dispose();
    super.dispose();
  }

  void onMenuVisibilityChanged() => swipeUpIconButtonController.toggle();

  void moveToNextPage() {
    currentPageIndex == wrappedCards.length - 1
        ? closeTreatment()
        : pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.decelerate);
  }

  void closeTreatment() {
    slideContainerController.forceSlide(SlideContainerDirection.topToBottom);
  }

  void onPageChanged(int index) {
    isCardPlaying = false;
    pagesViewedCount = max(pagesViewedCount, 1 + index);

    if (widget.onTreatmentCompleted != null && index >= wrappedCards.length - 2) {
      widget.onTreatmentCompleted();
    }

    if (index < visibilityChangedNotifiers.length) {
      visibilityChangedNotifiers[index]?.value = CardVisibilityChanged.onScreen;
    }
    if (index - 1 >= 0) {
      visibilityChangedNotifiers[index - 1]?.value = CardVisibilityChanged.offScreen;
    }
    if (index + 1 < visibilityChangedNotifiers.length) {
      visibilityChangedNotifiers[index + 1]?.value = CardVisibilityChanged.offScreen;
    }

    if (isCardWithoutFloatingButtons) {
      floatingButtonsAnimationController.reverse();
    } else {
      floatingButtonsAnimationController.forward();
    }

    presenter.isCardSaved(currentCard) ? heartButtonController.turnOn() : heartButtonController.turnOff();
  }

  void onCardStarted() {
    isCardPlaying = true;
    if (isCardUncompleted) cardTimerControllers[currentPageIndex]?.resume();
    presenter.onCardStarted(currentCard);
  }

  void onCommentInputChanged(String userInput) {
    setMountedState(() => treatmentTrackingData = treatmentTrackingData.cloneWith(comment: userInput));
  }

  void onRatingChanged(int userRating) {
    setMountedState(() => treatmentTrackingData = treatmentTrackingData.cloneWith(rating: userRating));
  }

  void onSlideComplete() {
    sendUserTreatmentCompletedData();
    presenter.updateDashboard();
  }

  void sendUserTreatmentCompletedData() {
    if (widget.treatment.isSpecial) return;
    // Start card and End card don't count.
    int cardsCompletedCount = min(pagesViewedCount - 1, widget.treatment.cards.length);
    if (cardsCompletedCount <= 0) return;
    presenter.sendTreatmentCompletedData(treatmentTrackingData.cloneWith(cardsCompletedCount: cardsCompletedCount));
  }

  void onSaveCardButtonPressed() {
    if (isCardWithoutFloatingButtons) return;
    presenter.saveOrRemoveCard(currentCard);
  }

  void onSwipeUpButtonPressed() {
    if (isCardWithoutFloatingButtons) return;
    menuController.toggleVisibility();
  }

  void onShareButtonPressed() {
    if (isCardWithoutFloatingButtons) return;
    presenter.openSharePage(currentCard);
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (!menuController.isHidden) {
            menuController.hide();
          } else {
            slideContainerController.forceSlide(SlideContainerDirection.topToBottom);
          }
          return false;
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            key: _scaffoldKey,

            /// Prevents the keyboard to push the layout when it appears/disappears.
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.transparent,
            body: SwipeGestureDetector(
              onSwipeValidated: (SwipeDirection direction) {
                if (!isCardWithoutFloatingButtons) {
                  if (direction == SwipeDirection.bottomToTop) {
                    menuController.show();
                  } else if (direction == SwipeDirection.topToBottom) {
                    menuController.hide();
                  }
                }
              },
              child: Stack(
                children: <Widget>[
                  pageView,
                  floatingButtons,
                  menu,
                ],
              ),
            ),
          ),
        ),
      );

  Widget get pageView => CloseTreatmentSlideContainer(
        controller: slideContainerController,
        onSlideCompleted: onSlideComplete,
        onSlide: (position) {
          if (!isCardWithoutFloatingButtons) {
            floatingButtonsAnimationController.value = 1 - position;
          }
        },
        child: CustomPageView.builder(
          physics: widget.treatment.isSpecial ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
          controller: pageController,
          itemCount: wrappedCards.length,
          cacheExtent: MediaQuery.of(context).size.width * 0.99,
          onPageChanged: onPageChanged,
          itemBuilder: (BuildContext context, int index) => buildCard(index),
        ),
      );

  Widget get menu => CardMenu(pageContextGetter: () => _pageContexts[currentPageIndex], scaffoldKey: _scaffoldKey);

  Widget get floatingButtons => Positioned(
        right: hugePadding - 5,
        bottom: BasicCardLayout.bottomElementsPositionFromBottom,
        child: AnimatedBuilder(
          animation: floatingButtonsAnimationController,
          builder: (context, child) => Visibility(
            visible: floatingButtonsAnimationController.value != 0,
            child: Opacity(opacity: floatingButtonsAnimationController.value, child: child),
          ),
          child: Container(
            height: 48,
            child: Row(
              children: <Widget>[
                AnimatedHeartButton(
                  controller: heartButtonController,
                  isOn: presenter.isCardSaved(currentCard),
                  isAnimationDisabledGetter: () => !presenter.isUserLoggedIn || isCardWithoutFloatingButtons,
                  onPressed: onSaveCardButtonPressed,
                ),
                Padding(padding: const EdgeInsets.only(left: 5)),
                SwipeUpIconButton(
                  controller: swipeUpIconButtonController,
                  onPressed: onSwipeUpButtonPressed,
                  quarterTurns: 0,
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildCard(int index) {
    DataCard card = wrappedCards[index];
    bool hasStartCard = wrappedCards.any((card) => card.isStartCard());
    PageContext pageContext = _pageContexts[index];
    if (card.isBasicCard()) {
      return BasicCard(pageContext);
    } else if (card.isAudioCard()) {
      // Audio cards and basic cards are now the same.
      return BasicCard(pageContext);
    } else if (card.isVideoCard()) {
      return VideoCard(pageContext);
    } else if (card.isDragCard()) {
      return DragCard(pageContext);
    } else if (card.isWildcardCard()) {
      return WildcardCard(pageContext);
    } else if (card.isMessagingCard()) {
      return MessagingCard(pageContext);
    } else if (card.isStoryCard()) {
      return StoryCard(pageContext);
    } else if (card.isUpsellCard()) {
      return UpsellCard(pageContext);
    } else if (card.isStartCard()) {
      return StartCard(
          pageContext: pageContext, preventTransitionAnimation: widget.preventStartCardTransitionAnimation);
    } else if (card.isEndCard()) {
      return EndCard(pageContext, onCommentInputChanged, onRatingChanged);
    } else {
      trackSilently("Card of type ${wrappedCards[index].type} is not supported");
      return ErrorCard(
        PageContext(
          treatment: widget.treatment,
          card: errorCard,
          onCardStarted: onCardStarted,
          onCardCompleted: () => presenter.onCardCompleted(currentCard),
          cardTimerController: cardTimerControllers[index],
          visibilityChangedNotifier: visibilityChangedNotifiers[index],
          onNextPressed: moveToNextPage,
          slideContainerController: slideContainerController,
          isRecommendedTreatment: widget.isRecommendedTreatment,
          hasStartCard: hasStartCard,
          menuController: menuController,
        ),
      );
    }
  }
}

@immutable
class PageContext {
  final CardOverlayMenuController menuController;
  final SlideContainerController slideContainerController;
  final Treatment treatment;
  final DataCard card;
  final CardTimerController cardTimerController;
  final ValueNotifier<CardVisibilityChanged> visibilityChangedNotifier;
  final VoidCallback onCardStarted;
  final VoidCallback onCardCompleted;
  final VoidCallback onNextPressed;
  final bool isRecommendedTreatment;
  final bool hasStartCard;

  PageContext({
    @required this.treatment,
    @required this.card,
    @required this.onCardStarted,
    @required this.onCardCompleted,
    @required this.visibilityChangedNotifier,
    @required this.onNextPressed,
    @required this.slideContainerController,
    @required this.isRecommendedTreatment,
    @required this.hasStartCard,
    @required this.cardTimerController,
    @required this.menuController,
  });
}
