import 'dart:async';
import 'dart:ui';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/widgets/active_ingredient_icon.dart';
import 'package:aebeze/cards/widgets/active_ingredient_text.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/buttons/card_timer.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:aebeze/widgets/equation_screen.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnBoardingAnimatedBackgroundCardLayout extends BasicCardLayout {
  final String activeIngredientText = "activeIngredientText";
  final String overlayScreen = "overlayScreen";
  final bool isFirstCard;

  OnBoardingAnimatedBackgroundCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded, this.isFirstCard)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutOverlayScreen(context, size, layoutChild, positionChild);
    layoutTimer(context, size, layoutChild, positionChild);
  }

  void layoutActiveIngredientText(
      BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(activeIngredientText, BoxConstraints.tightFor());
    positionChild(
      activeIngredientText,
      Offset(defaultPadding, MediaQuery.of(context).padding.top - 30.0),
    );
  }

  void layoutOverlayScreen(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(overlayScreen, BoxConstraints.tightFor(width: size.width, height: size.height));
    positionChild(
      overlayScreen,
      Offset(0.0, 0),
    );
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addOverlayScreen(list);
    addTimer(list);
    return list;
  }

  void addOverlayScreen(LayoutList list) {
    list.layout(overlayScreen, () => _OverlayScreen(card, pageContext, isFirstCard));
  }

  void addActiveIngredientText(LayoutList list) => list.layout(
        activeIngredientText,
        () => ActiveIngredientText(
          activeIngredients: pageContext.card.activeIngredients,
          color: stringToColor(pageContext.treatment.color),
        ),
      );
}

class _OverlayScreen extends StatefulWidget {
  final DataCard card;
  final PageContext pageContext;
  final bool isFirstCard;

  _OverlayScreen(this.card, this.pageContext, this.isFirstCard);

  @override
  _OverlayScreenState createState() => _OverlayScreenState();
}

class _OverlayScreenState extends SafeState<_OverlayScreen> with TickerProviderStateMixin {
  AnimationController animationController;
  AnimationController showArrowAnimationController;
  AnimationController childAnimationController;
  Animation<double> firstAnimation;
  Animation<double> secondAnimation;
  Animation<double> secondOutAnimation;
  Animation<double> thirdAnimation;
  Timer firstCardTimer;

  @override
  void initState() {
    widget.pageContext.cardTimerController?.addListener(onCardTimerUpdated);
    animationController = AnimationController(duration: Duration(seconds: 8), vsync: this)..addListener(refreshState);
    childAnimationController = AnimationController(vsync: this);
    showArrowAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300))
      ..addListener(refreshState);
    firstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
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
        parent: animationController,
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
        parent: animationController,
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
        parent: animationController,
        curve: Interval(
          0.6,
          0.8,
          curve: Curves.linear,
        ),
      ),
    );
    widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);
    if (widget.isFirstCard) {
      firstCardTimer = Timer(Duration(seconds: 2), () {
        widget.pageContext.cardTimerController.resume();
        animationController.forward();
      });
    }

    super.initState();
  }

  void onVisibilityChanged() {
    if (widget.pageContext.visibilityChangedNotifier.value == CardVisibilityChanged.onScreen) {
      childAnimationController.forward().then((_) => animationController.forward());
    }
  }

  void onCardTimerUpdated() {
    if (widget.pageContext.cardTimerController.status == TimerStatus.completed) {
      showArrowAnimationController.forward();
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    showArrowAnimationController?.dispose();
    firstCardTimer?.cancel();
    widget.pageContext.visibilityChangedNotifier.removeListener(onVisibilityChanged);
    widget.pageContext.cardTimerController?.removeListener(onCardTimerUpdated);
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

  Widget get signUpButton => GestureDetector(
        onTap: widget.pageContext.onNextPressed,
        child: Container(
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 10),
          color: Colors.transparent,
          child: TextScaled(
            localize(context, "button_sign_up").toUpperCase(),
            style: AppTextStyles.instruction.copyWith(color: Colors.white),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.isFirstCard ? SnowVideoWidget() : EquationScreen(childAnimationController),
          Container(
            color: Color.fromARGB((firstAnimation.value * (widget.isFirstCard ? 0 : 255)).toInt(), 0, 0, 0),
            child: Stack(
              children: [
                widget.card.activeIngredients != null
                    ? Positioned(
                        top: 0.5 * MediaQuery.of(context).padding.top + 25,
                        left: defaultPadding - 8.0,
                        child: Opacity(
                          child: ActiveIngredientIcon(
                            cardActiveIngredients: widget.card.activeIngredients,
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
                      widget.card.messages[0].message,
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
                      widget.card.messages[1].message,
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
                      child: App.isDayBreak && widget.card.uid == "onboardingCard4"
                          ? signUpButton
                          : ArrowIconButton(
                              quarterTurns: 2,
                              onPressed: widget.pageContext.onNextPressed,
                              color: cardOpposingColor(widget.pageContext.card.background),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class SnowVideoWidget extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SnowVideoWidget> {
  VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.asset(Assets.justSnowing)
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize()
      ..play();
  }

  @override
  Widget build(BuildContext context) => VideoPlayer(videoController);
}
