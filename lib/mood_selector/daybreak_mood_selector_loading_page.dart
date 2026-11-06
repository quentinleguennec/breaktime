import 'dart:async';
import 'dart:ui';

import 'package:aebeze/assets.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';

class DaybreakMoodSelectorLoading extends StatefulWidget {
  final VoidCallback onLoadingAnimationCompleted;
  final ValueNotifier<bool> onLoadingNotifier;

  DaybreakMoodSelectorLoading({this.onLoadingAnimationCompleted, this.onLoadingNotifier});

  @override
  _MoodSelectorLoadingState createState() => _MoodSelectorLoadingState();
}

class _MoodSelectorLoadingState extends BasePresenter<DaybreakMoodSelectorLoading> with TickerProviderStateMixin {
  static const Duration opacityAnimationDuration = const Duration(milliseconds: 700);
  static const Duration textOpacityAnimationDuration = const Duration(milliseconds: 500);
  static const Duration logoOpacityAnimationDuration = const Duration(milliseconds: 700);

  AnimationController opacityAnimationController;
  AnimationController textOpacityAnimationController;
  AnimationController logoOpacityAnimationController;
  Animation<double> opacityAnimation;
  Animation<double> textOpacityAnimation;
  Animation<double> logoOpacityAnimation;
  VoidCallback loadingNotifierListener;

  @override
  void initState() {
    textOpacityAnimationController = AnimationController(duration: textOpacityAnimationDuration, vsync: this);
    textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: textOpacityAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    logoOpacityAnimationController = AnimationController(duration: logoOpacityAnimationDuration, vsync: this);
    logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: logoOpacityAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    opacityAnimationController = AnimationController(duration: opacityAnimationDuration, vsync: this);
    opacityAnimationController.addListener(refreshState);
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: opacityAnimationController,
        curve: Curves.easeOut,
      ),
    );

    logoOpacityAnimationController.forward().then((_) {
      textOpacityAnimationController.forward().then((_) {
        widget.onLoadingAnimationCompleted();
      });
    });

    loadingNotifierListener = () {
      //Removing loading screen only on data loading && animation end
      if (!widget.onLoadingNotifier.value) {
        // Add a timer to improve the animation.
        Timer(
          Duration(milliseconds: 20),
          () => textOpacityAnimationController.reverse().then(
                (_) => logoOpacityAnimationController.reverse().then(
                      (_) => opacityAnimationController.forward(),
                    ),
              ),
        );
      }
    };
    registerListenerOnNotifier();
    super.initState();
  }

  void registerListenerOnNotifier() {
    widget.onLoadingNotifier.addListener(loadingNotifierListener);
  }

  @override
  void didUpdateWidget(var oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.onLoadingNotifier.removeListener(loadingNotifierListener);
    registerListenerOnNotifier();
  }

  @override
  void dispose() {
    opacityAnimationController?.dispose();
    textOpacityAnimationController?.dispose();
    logoOpacityAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Visibility(
        child: Opacity(
          opacity: opacityAnimation.value,
          child: Content(
            logoOpacityAnimation: logoOpacityAnimation,
            textOpacityAnimation: textOpacityAnimation,
          ),
        ),
        visible: !opacityAnimationController.isCompleted,
      );
}

class Content extends StatelessWidget {
  final Animation<double> logoOpacityAnimation;
  final Animation<double> textOpacityAnimation;

  Content({
    @required this.logoOpacityAnimation,
    @required this.textOpacityAnimation,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.7],
                colors: [
                  AppColors.daybreakSplash,
                  Colors.black,
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: logoOpacityAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.asset(Assets.daybreakLogo),
            ),
            builder: (context, child) => Align(
              alignment: FractionalOffset(0.62, 0.45),
              child: Opacity(
                opacity: logoOpacityAnimation.value,
                child: child,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: textOpacityAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "Daybreak",
                  style: AppTextStyles.daybreakSplashScreenTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            builder: (context, child) => Align(
              alignment: FractionalOffset(0.5, 0.49),
              child: Opacity(
                opacity: textOpacityAnimation.value,
                child: child,
              ),
            ),
          ),
        ],
      );
}
