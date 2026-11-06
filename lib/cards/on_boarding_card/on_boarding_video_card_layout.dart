import 'dart:async';
import 'dart:ui';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/widgets/active_ingredient_icon.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/buttons/card_timer.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class OnBoardingVideoCardLayout extends BasicCardLayout {
  static final String overlayScreen = "overlayScreen";
  static final String activeIngredientText = "activeIngredientText";

  OnBoardingVideoCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundVideo(context, size, layoutChild, positionChild);
    layoutOverlayScreen(context, size, layoutChild, positionChild);
    layoutTimer(context, size, layoutChild, positionChild);
  }

  void layoutOverlayScreen(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(overlayScreen, BoxConstraints.tightFor(width: size.width, height: size.height));
    positionChild(
      overlayScreen,
      Offset(0, 0),
    );
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundVideo(list);
    addOverlayScreen(list);
    addTimer(list);
    return list;
  }

  void addOverlayScreen(LayoutList list) {
    list.layout(overlayScreen, () => _OverlayScreen(pageContext));
  }
}

class _OverlayScreen extends StatefulWidget {
  final PageContext pageContext;

  _OverlayScreen(this.pageContext);

  @override
  _OverlayScreenState createState() => _OverlayScreenState();
}

class _OverlayScreenState extends SafeState<_OverlayScreen> with TickerProviderStateMixin {
  AnimationController controller;
  AnimationController showArrowAnimationController;
  Animation<double> firstAnimation;
  Animation<double> secondAnimation;
  Animation<double> secondOutAnimation;
  Animation<double> thirdAnimation;
  Timer visibilityChangedTimer;

  @override
  void initState() {
    widget.pageContext.cardTimerController?.addListener(onCardTimerUpdated);
    controller = AnimationController(vsync: this, duration: Duration(seconds: 7))..addListener(refreshState);
    showArrowAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300))
      ..addListener(refreshState);
    firstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0,
          0.1,
          curve: Curves.linear,
        ),
      ),
    );
    secondAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.15,
          0.35,
          curve: Curves.linear,
        ),
      ),
    );
    secondOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.45,
          0.6,
          curve: Curves.linear,
        ),
      ),
    );

    thirdAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.6,
          0.8,
          curve: Curves.linear,
        ),
      ),
    );

    widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);
    super.initState();
  }

  void onVisibilityChanged() {
    if (widget.pageContext.visibilityChangedNotifier.value == CardVisibilityChanged.onScreen) {
      visibilityChangedTimer = Timer(Duration(seconds: 2), () => controller.forward());
    }
  }

  void onCardTimerUpdated() {
    if (widget.pageContext.cardTimerController.status == TimerStatus.completed) {
      showArrowAnimationController.forward();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    showArrowAnimationController?.dispose();
    widget.pageContext.visibilityChangedNotifier.removeListener(onVisibilityChanged);
    widget.pageContext.cardTimerController?.removeListener(onCardTimerUpdated);
    visibilityChangedTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_OverlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.visibilityChangedNotifier.removeListener(onVisibilityChanged);
    widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);
    oldWidget.pageContext.cardTimerController?.removeListener(onCardTimerUpdated);
    widget.pageContext.cardTimerController?.addListener(onCardTimerUpdated);
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.4 * firstAnimation.value),
        child: Stack(
          children: [
            widget.pageContext.card.activeIngredients != null
                ? Positioned(
                    top: 0.5 * MediaQuery.of(context).padding.top + 25,
                    left: defaultPadding - 8.0,
                    child: Opacity(
                      child: ActiveIngredientIcon(
                        cardActiveIngredients: widget.pageContext.card.activeIngredients,
                      ),
                      opacity: firstAnimation.value,
                    ),
                  )
                : Container(),
            Positioned(
              top: 170 * (MediaQuery.of(context).size.height / defaultScreenHeight),
              left: defaultPadding,
              right: 50,
              child: Opacity(
                opacity: secondAnimation.value < 1 ? secondAnimation.value : secondOutAnimation.value,
                child: TextScaled(
                  widget.pageContext.card.messages[0].message,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                  textScaleFactor: MediaQuery.of(context).size.width / defaultScreenWidth,
                ),
              ),
            ),
            Positioned(
              top: 400 * (MediaQuery.of(context).size.height / defaultScreenHeight),
              left: defaultPadding,
              right: 50,
              child: Opacity(
                opacity: thirdAnimation.value,
                child: TextScaled(
                  widget.pageContext.card.messages[1].message,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                  textScaleFactor: MediaQuery.of(context).size.width / defaultScreenWidth,
                ),
              ),
            ),
            Positioned(
              bottom: 48 + MediaQuery.of(context).padding.bottom,
              right: 10,
              child: Visibility(
                visible: showArrowAnimationController.value != 0,
                child: Opacity(
                  opacity: showArrowAnimationController.value,
                  child: ArrowIconButton(
                    quarterTurns: 2,
                    onPressed: widget.pageContext.onNextPressed,
                    color: cardOpposingColor(widget.pageContext.card.background),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
