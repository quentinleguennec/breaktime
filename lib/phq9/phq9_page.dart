import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/card_overlay_menu_controller.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/error_card.dart';
import 'package:aebeze/cards/phq9_card/phq9_question_card.dart';
import 'package:aebeze/cards/phq9_card/phq9_result_card.dart';
import 'package:aebeze/cards/phq9_card/phq9_start_card.dart';
import 'package:aebeze/cards/widgets/custom_page_view.dart';
import 'package:aebeze/phq9/phq9_presenter.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/close_treatment_slide_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:screen/screen.dart';
import 'package:slide_container/slide_container.dart';
import 'package:slide_container/slide_container_controller.dart';

class PHQ9Page extends PopupRoute<Null> {
  PHQ9Page() : super(settings: TrackingService.phq9Page);

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => false;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => const Duration(microseconds: 1);

  @override
  Widget buildPage(_, __, ___) => _PageLayout();
}

class _PageLayout extends StatefulWidget {
  _PageLayout();

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements PHQ9PresenterView {
  final SlideContainerController slideContainerController = SlideContainerController();
  final PageController pageController = PageController();

  PHQ9Presenter presenter;
  bool isCardPlaying = false;
  List<ValueNotifier<CardVisibilityChanged>> _visibilityChangedNotifiers;
  int score = 0;

  DataCard get currentCard => wrappedCards[currentPageIndex];

  List<DataCard> get wrappedCards => presenter.wrappedCards;

  List<ValueNotifier<CardVisibilityChanged>> get visibilityChangedNotifiers {
    if (_visibilityChangedNotifiers == null) {
      _visibilityChangedNotifiers = List<ValueNotifier<CardVisibilityChanged>>(wrappedCards.length);
    }
    return _visibilityChangedNotifiers;
  }

  int get currentPageIndex {
    if (!pageController.hasClients) {
      return 0;
    }
    try {
      return pageController.page.round();
    } catch (e) {
      // TODO: As of Flutter 0.5.1 there is a bug where "controller.page" throw an error when called before the PageView is fully initialized.
      // This try/catch shouldn't be needed, it's just a work around for this issue. Remove it when the bug in the framework is fixed.
      // Cf: https://github.com/flutter/flutter/issues/18370
      return 0;
    }
  }

  _PageLayoutState() {
    presenter = PHQ9Presenter(this);
  }

  @override
  void initState() {
    Screen.keepOn(true);
    super.initState();
  }

  @override
  void dispose() {
    Screen.keepOn(false);
    visibilityChangedNotifiers?.forEach((notifier) => notifier?.dispose());
    pageController?.dispose();
    super.dispose();
  }

  void moveToNextPage() {
    currentPageIndex == wrappedCards.length - 1 || currentPageIndex == 3 && score <= 2
        ? slideContainerController.forceSlide(SlideContainerDirection.topToBottom)
        : pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.decelerate);
  }

  void onPageChanged(int index) {
    if (index < visibilityChangedNotifiers.length) {
      visibilityChangedNotifiers[index]?.value = CardVisibilityChanged.onScreen;
    }
    if (index - 1 >= 0) {
      visibilityChangedNotifiers[index - 1]?.value = CardVisibilityChanged.offScreen;
    }
    if (index + 1 < visibilityChangedNotifiers.length) {
      visibilityChangedNotifiers[index + 1]?.value = CardVisibilityChanged.offScreen;
    }
  }

  void onQuestionAnswered(int weight) {
    score += weight;

    /// If the score is high skip the first result card and fake the transition (the 5th card is a copy of the 2nd question card).
    if (currentPageIndex == 2 && score > 2) {
      pageController.jumpToPage(4);
    }
    moveToNextPage();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          slideContainerController.forceSlide(SlideContainerDirection.topToBottom);
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: buildPageView(),
        ),
      );

  Widget buildPageView() => CloseTreatmentSlideContainer(
        controller: slideContainerController,
        child: CustomPageView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          itemCount: wrappedCards.length,
          cacheExtent: MediaQuery.of(context).size.width * 0.99,
          onPageChanged: onPageChanged,
          itemBuilder: (BuildContext context, int index) {
            CardVisibilityChanged cardVisibility =
                index == currentPageIndex ? CardVisibilityChanged.onScreen : CardVisibilityChanged.offScreen;
            if (visibilityChangedNotifiers[index] == null) {
              visibilityChangedNotifiers[index] = ValueNotifier<CardVisibilityChanged>(cardVisibility);
            } else {
              visibilityChangedNotifiers[index].value = cardVisibility;
            }
            return buildCard(index);
          },
        ),
      );

  Widget buildCard(int index) {
    DataCard card = wrappedCards[index];
    bool hasStartCard = wrappedCards.any((card) => card.isPHQ9StartCard());
    PageContext pageContext = PageContext(
      card: card,
      visibilityChangedNotifier: visibilityChangedNotifiers[index],
      onNextPressed: moveToNextPage,
      slideContainerController: slideContainerController,
      treatment: null,
      onCardStarted: null,
      onCardCompleted: null,
      cardTimerController: null,
      isRecommendedTreatment: false,
      hasStartCard: hasStartCard,
      menuController: CardOverlayMenuController(),
    );

    if (card.isPHQ9StartCard()) {
      return PHQ9StartCard(pageContext);
    }
    if (card.isPHQ9QuestionCard()) {
      return PHQ9QuestionCard(
        pageContext,
        onQuestionAnswered,
      );
    }
    if (card.isPHQ9ResultCard()) {
      return PHQ9ResultCard(
        pageContext,
        () => score,
      );
    } else {
      trackSilently("Card of type ${wrappedCards[index].type} is not supported");
      return ErrorCard(
        PageContext(
          card: errorCard,
          visibilityChangedNotifier: visibilityChangedNotifiers[index],
          onNextPressed: moveToNextPage,
          slideContainerController: slideContainerController,
          treatment: null,
          onCardStarted: null,
          onCardCompleted: null,
          cardTimerController: null,
          isRecommendedTreatment: false,
          hasStartCard: hasStartCard,
          menuController: CardOverlayMenuController(),
        ),
      );
    }
  }
}
