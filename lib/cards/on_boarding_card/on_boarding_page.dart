import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/card_overlay_menu_controller.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/on_boarding_card/on_boarding_animated_background_card.dart';
import 'package:aebeze/cards/on_boarding_card/on_boarding_video_card.dart';
import 'package:aebeze/cards/widgets/custom_page_view.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/buttons/card_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:screen/screen.dart';
import 'package:slide_container/slide_container.dart';
import 'package:slide_container/slide_container_controller.dart';

class OnBoardingPage extends StatefulWidget {
  final VoidCallback onGetStartedButtonPressed;

  OnBoardingPage({@required this.onGetStartedButtonPressed});

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<OnBoardingPage> with TickerProviderStateMixin {
  final SlideContainerController slideContainerController = SlideContainerController();
  final PageController pageController = PageController();

  List<ValueNotifier<CardVisibilityChanged>> _visibilityChangedNotifiers;
  List<CardTimerController> _cardTimerControllers;

  DataCard get currentCard => wrappedCards[currentPageIndex];

  List<DataCard> get wrappedCards {
    return [
      OnBoardingAnimatedBackgroundCard.cards[0],
      OnBoardingVideoCard.cards[0],
      OnBoardingVideoCard.cards[1],
      OnBoardingAnimatedBackgroundCard.cards[1],
    ];
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
      // TODO: As of Flutter 0.5.1 there is a bug where "controller.page" throw an error when called before the PageView is fully initialized.
      // This try/catch shouldn't be needed, it's just a work around for this issue. Remove it when the bug in the framework is fixed.
      // Cf: https://github.com/flutter/flutter/issues/18370
      return 0;
    }
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
    currentPageIndex == wrappedCards.length - 1
        ? widget.onGetStartedButtonPressed()
        : pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.decelerate);
  }

  void onPageChanged(int index) {
    if (index < visibilityChangedNotifiers.length) {
      visibilityChangedNotifiers[index]?.value = CardVisibilityChanged.onScreen;
      cardTimerControllers[index].resume();
    }
    if (index - 1 >= 0) {
      visibilityChangedNotifiers[index - 1]?.value = CardVisibilityChanged.offScreen;
    }
    if (index + 1 < visibilityChangedNotifiers.length) {
      visibilityChangedNotifiers[index + 1]?.value = CardVisibilityChanged.offScreen;
    }
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

  Widget buildPageView() => CustomPageView.builder(
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
      );

  Widget buildCard(int index) {
    DataCard card = wrappedCards[index];
    PageContext pageContext = PageContext(
      card: card,
      visibilityChangedNotifier: visibilityChangedNotifiers[index],
      onNextPressed: moveToNextPage,
      slideContainerController: slideContainerController,
      treatment: Treatment(color: "0xffffffff", cards: wrappedCards),
      onCardStarted: () {},
      onCardCompleted: () {},
      cardTimerController: cardTimerControllers[index],
      isRecommendedTreatment: false,
      hasStartCard: false,
      menuController: CardOverlayMenuController(),
    );

    if (index == 1 || index == 2) {
      return OnBoardingVideoCard(pageContext);
    } else {
      return OnBoardingAnimatedBackgroundCard(pageContext, index == 0);
    }
  }
}
