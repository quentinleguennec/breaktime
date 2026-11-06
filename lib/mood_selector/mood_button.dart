import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/view_utils.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MoodButton extends AnimatedWidget {
  static const Duration cascadeDuration = const Duration(milliseconds: 100);
  static const Duration cascadeDelay = const Duration(milliseconds: 50);

  final String text;
  final Animation cascadingRevealAnimation;
  final Animation activeStateAnimation;

  MoodButton({
    @required this.text,
    this.cascadingRevealAnimation,
    this.activeStateAnimation,
  }) : super(listenable: Listenable.merge([cascadingRevealAnimation, activeStateAnimation]..removeWhere(isNull)));

  double get activeStateAnimationValue => activeStateAnimation?.value ?? 0;

  Color get buttonInsideColor => Color.lerp(
        AppColors.moodButtonBackgroundOff,
        AppColors.moodButtonBackgroundOn,
        activeStateAnimationValue,
      );

  Color get buttonBorderColor => Color.lerp(
        Colors.white,
        AppColors.moodButtonBackgroundOn,
        activeStateAnimationValue,
      );

  Color get textColor => Color.lerp(
        AppColors.moodButtonTextOff,
        AppColors.moodButtonTextOn,
        activeStateAnimationValue,
      );

  Widget get content => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
            borderRadius: new BorderRadius.circular(4.0),
            border: Border.all(
              width: 1,
              color: buttonBorderColor,
            ),
            color: buttonInsideColor),
        child: TextScaled(
          text,
          style: AppTextStyles.caption.copyWith(
            color: textColor,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => cascadingRevealAnimation == null
      ? content
      : _AnimatedRevealWidget(
          animation: cascadingRevealAnimation,
          translationValue: 10.0,
          child: content,
        );
}

class _AnimatedRevealWidget extends AnimatedWidget {
  static const double startingScale = 0.7;
  final Widget child;
  final Animation<double> animation;
  final double translationValue;
  final double opacityValue;

  _AnimatedRevealWidget({
    @required this.child,
    @required this.animation,
    this.translationValue = 10.0,
    this.opacityValue = 1.0,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacityValue == null ? 1.0 : animation.value * opacityValue,
        child: Transform.scale(
          scale: startingScale + animation.value * (1 - startingScale),
          child: child,
        ),
      );
}
