import 'dart:async';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/reveal_container.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const Duration cardHoldMilliseconds = const Duration(milliseconds: 3000);
const Duration cardAnimationDuration = const Duration(milliseconds: 1000);
const double controlsEaseInStart = 0.3;
const double pillLoaderHeight = 38.0;
const double pillLoaderExpansion = defaultPadding;

class CardAnimator {
  AnimationController animationController;
  Animation<double> controlsAnimation;
  Animation<double> placementsAnimation;

  CardAnimator(DataCard card, TickerProviderStateMixin vsync) {
    animationController = AnimationController(vsync: vsync, duration: cardAnimationDuration);
    controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Interval(controlsEaseInStart, 1.0, curve: Curves.easeIn)));
    placementsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          0.0,
          controlsEaseInStart,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  TickerFuture reverse() => animationController?.reverse();

  TickerFuture forward() => animationController?.forward();

  void reset() => animationController?.reset();

  void dispose() => animationController?.dispose();

  Widget controlsRevealAnimation(Widget child) =>
      controlsAnimation != null ? RevealContainer(controlsAnimation, child: child) : child;

  Widget placementRevealAnimation(Widget child) =>
      placementsAnimation != null ? RevealContainer(placementsAnimation, child: child) : child;
}

enum CardVisibilityChanged { onScreen, offScreen }

class BasicCard extends StatefulWidget {
  final PageContext pageContext;

  BasicCard(this.pageContext) : super(key: Key(pageContext.card.uid));

  @override
  BasicCardState createState() => BasicCardState();
}

class BasicCardState extends SafeState<BasicCard> with TickerProviderStateMixin {
  CardAnimator animator;
  bool isBackgroundVideoLoaded;
  bool isBackgroundImageLoaded;
  Timer hidePlacementsTimer;
  bool placementWasShown = false;

  bool get isCardReady =>
      widget.pageContext.menuController.isHidden &&
      widget.pageContext.visibilityChangedNotifier.value != CardVisibilityChanged.offScreen;

  bool get shouldShowPlacement =>
      isBackgroundVideoLoaded && isBackgroundImageLoaded && isCardReady && !placementWasShown;

  @override
  void initState() {
    super.initState();
    isBackgroundVideoLoaded = !widget.pageContext.card.hasBackgroundVideo();
    isBackgroundImageLoaded = !widget.pageContext.card.hasBackgroundImage();
    if (animator == null) {
      animator = CardAnimator(widget.pageContext.card, this);
    } else {
      animator.reset();
    }
    registerPositionListener();
  }

  void registerPositionListener() {
    if (shouldShowPlacement) {
      showPlacements();
    } else {
      widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);
      widget.pageContext.menuController.addListener(onVisibilityChanged);
    }
  }

  @override
  void dispose() {
    hidePlacementsTimer?.cancel();
    animator?.dispose();
    widget.pageContext.visibilityChangedNotifier?.removeListener(onVisibilityChanged);
    widget.pageContext.menuController?.removeListener(onVisibilityChanged);
    widget.pageContext.cardTimerController?.reset();
    super.dispose();
  }

  @override
  void didUpdateWidget(BasicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.visibilityChangedNotifier.removeListener(onVisibilityChanged);
    oldWidget.pageContext.menuController.removeListener(onVisibilityChanged);
    registerPositionListener();
  }

  void onVisibilityChanged() {
    if (shouldShowPlacement) {
      showPlacements();
      startCardIfReady();
    } else if (!isCardReady) {
      widget.pageContext.cardTimerController?.pause();
    }
  }

  void onBackgroundVideoLoaded() {
    isBackgroundVideoLoaded = true;
    if (shouldShowPlacement) {
      showPlacements();
      startCardIfReady();
    }
  }

  void onBackgroundImageLoaded() {
    isBackgroundImageLoaded = true;
    if (shouldShowPlacement) {
      showPlacements();
      startCardIfReady();
    }
  }

  void startCardIfReady() {
    if (widget.pageContext.onCardStarted != null) widget.pageContext.onCardStarted();
  }

  void showPlacements() => animator.forward().then((_) {
        placementWasShown = true;
        if (!widget.pageContext.card.isAudioCard() && !widget.pageContext.card.isVideoCard()) {
          hidePlacementsTimer = Timer(cardHoldMilliseconds, () => animator.reverse());
        }
      });

  @override
  Widget build(BuildContext context) => buildCardLayout(widget, animator);

  Widget buildCardLayout(BasicCard widget, CardAnimator animator) => BasicCardLayout(
        widget.pageContext,
        animator,
        onBackgroundVideoLoaded,
        onBackgroundImageLoaded,
      );
}
