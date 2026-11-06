import 'dart:async';
import 'dart:ui';

import 'package:aebeze/assets.dart';
import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle.dart';
import 'package:aebeze/mood_selector/widgets/animated_colored_circle.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';

class MoodSelectorLoading extends StatefulWidget {
  final VoidCallback onLoadingAnimationCompleted;
  final ValueNotifier<bool> onLoadingNotifier;

  MoodSelectorLoading({this.onLoadingAnimationCompleted, this.onLoadingNotifier});

  @override
  _MoodSelectorLoadingState createState() => _MoodSelectorLoadingState();
}

class _MoodSelectorLoadingState extends BasePresenter<MoodSelectorLoading> with TickerProviderStateMixin {
  static const Duration centerCircleAnimationDuration = const Duration(milliseconds: 700);
  static const Duration bottomCirclesAnimationDuration = const Duration(milliseconds: 500);
  static const Duration opacityAnimationDuration = const Duration(milliseconds: 700);
  static const Duration textOpacityAnimationDuration = const Duration(milliseconds: 500);

  AnimationController centerCircleAnimationController;
  AnimationController bottomCirclesAnimationController;
  AnimationController opacityAnimationController;
  AnimationController textOpacityAnimationController;
  Animation<double> centerCircleAnimation;
  Animation<double> bottomCirclesAnimation;
  Animation<double> opacityAnimation;
  Animation<double> textOpacityAnimation;
  VoidCallback loadingNotifierListener;
  Timer outStartTimer;
  bool hideCircle = false;

  @override
  void initState() {
    centerCircleAnimationController = AnimationController(duration: centerCircleAnimationDuration, vsync: this);
    centerCircleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: centerCircleAnimationController,
        curve: Curves.easeIn,
      ),
    );
    bottomCirclesAnimationController = AnimationController(duration: bottomCirclesAnimationDuration, vsync: this);
    bottomCirclesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: bottomCirclesAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    textOpacityAnimationController = AnimationController(duration: textOpacityAnimationDuration, vsync: this);
    textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: textOpacityAnimationController,
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

    triggerInAnimation();

    loadingNotifierListener = () {
      //Removing loading screen only on data loading && animation end
      if (!widget.onLoadingNotifier.value) {
        // Add a timer to improve the animation.
        outStartTimer = Timer(Duration(milliseconds: 20), () => triggerOutAnimation());
      }
    };

    registerListenerOnNotifier();

    super.initState();
  }

  void registerListenerOnNotifier() => widget.onLoadingNotifier.addListener(loadingNotifierListener);

  @override
  void didUpdateWidget(var oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.onLoadingNotifier.removeListener(loadingNotifierListener);
    registerListenerOnNotifier();
  }

  @override
  void dispose() {
    opacityAnimationController?.dispose();
    centerCircleAnimationController?.dispose();
    bottomCirclesAnimationController?.dispose();
    textOpacityAnimationController?.dispose();
    outStartTimer?.cancel();
    super.dispose();
  }

  void triggerInAnimation() async {
    await bottomCirclesAnimationController.forward();
    await centerCircleAnimationController.forward();
    await textOpacityAnimationController.forward();
    widget.onLoadingAnimationCompleted?.call();
  }

  void triggerOutAnimation() async {
    await textOpacityAnimationController.reverse();
    await centerCircleAnimationController.reverse();
    setMountedState(() => hideCircle = true);
    bottomCirclesAnimationController.value = 0;
    await opacityAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) => Visibility(
        visible: !opacityAnimationController.isCompleted,
        child: Opacity(
          opacity: opacityAnimation.value,
          child: Content(
            centerCircleAnimation: centerCircleAnimation,
            textOpacityAnimation: textOpacityAnimation,
            bottomCirclesAnimation: bottomCirclesAnimation,
            hideCircle: hideCircle,
          ),
        ),
      );
}

class Content extends StatelessWidget {
  final Animation<double> centerCircleAnimation;
  final Animation<double> textOpacityAnimation;
  final Animation<double> bottomCirclesAnimation;
  final bool hideCircle;

  double getCircleDiameter(BuildContext context) => MediaQuery.of(context).size.width * 0.45;

  Content({
    @required this.centerCircleAnimation,
    @required this.textOpacityAnimation,
    @required this.bottomCirclesAnimation,
    @required this.hideCircle,
  });

  Widget buildBackground(BuildContext context) => ClipRect(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: MoodSelectorBundle.backgroundGradientColors,
            ),
          ),
        ),
      );

  Widget buildMiddleGround(BuildContext context) => AnimatedBuilder(
        animation: bottomCirclesAnimation,
        builder: (context, child) => Opacity(
          opacity: bottomCirclesAnimation.value,
          child: child,
        ),
        child: CustomPaint(painter: FakeColorWheelPainter()),
      );

  Widget buildForeground(BuildContext context) => AnimatedColoredCircle(
        animation: centerCircleAnimation,
        diameter: getCircleDiameter(context),
        topColors: AppColors.logoTopColors,
        bottomColors: AppColors.logoBottomColors,
      );

  Widget buildText(BuildContext context) => AnimatedBuilder(
        animation: textOpacityAnimation,
        child: Image.asset(Assets.moodriseLogo),
        builder: (context, child) => Opacity(
          opacity: textOpacityAnimation.value,
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          buildBackground(context),
          buildMiddleGround(context),
          if (!hideCircle)
            Align(
              alignment: Alignment(0, -0.2),
              child: buildForeground(context),
            ),
          Align(
            alignment: Alignment(0, -0.2),
            child: Container(
              padding: const EdgeInsets.only(top: 14),
              width: MediaQuery.of(context).size.width * 0.6,
              child: buildText(context),
            ),
          ),
        ],
      );
}

class FakeColorWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double innerCircleDiameter = 3.45 * size.height;
    final double ovalWidth = 1.6 * size.width;
    final double ovalHeight = 1.3 * size.height;
    final double ovalHeightOffset = 0.39 * size.height;
    final double innerCircleEdgeDistanceFromBottom = 0.165 * size.height;
    final double circlesHeightOffset = (innerCircleDiameter * 0.5 - size.height) + innerCircleEdgeDistanceFromBottom;
    final Offset innerCircleOrigin = Offset(
      size.width / 2 - innerCircleDiameter / 2,
      -innerCircleDiameter * 0.5 - circlesHeightOffset,
    );
    final Offset ovalOrigin = Offset(
      -(ovalWidth - size.width) * 0.5,
      -(ovalHeight - size.height) * 0.5 - ovalHeightOffset,
    );
    final Rect innerCircleRect = innerCircleOrigin & Size(innerCircleDiameter, innerCircleDiameter);
    final Rect ovalRect = ovalOrigin & Size(ovalWidth, ovalHeight);
    // DrawRect can be used here (because the circle can't rotate) and is apparently a lot less expensive than drawing the giant circle.
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.splashCircleInner);
    canvas.drawOval(innerCircleRect, Paint()..color = AppColors.splashCircleOuter);
    canvas.drawOval(ovalRect, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(oldDelegate) => false;
}

class InvertedCircleClipper extends CustomClipper<Path> {
  final double diameter;
  final Offset center;

  InvertedCircleClipper({this.center, this.diameter = 200});

  @override
  Path getClip(Size size) => Path()
    ..addOval(Rect.fromCircle(center: center, radius: diameter * 0.5))
    ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
