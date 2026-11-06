import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedColoredCircle extends AnimatedWidget {
  final Animation<double> animation;
  final double diameter;
  final List<Color> topColors;
  final List<Color> bottomColors;

  AnimatedColoredCircle({
    @required this.animation,
    @required this.diameter,
    this.topColors,
    this.bottomColors,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => Transform.scale(
        scale: animation.status == AnimationStatus.reverse || animation.status == AnimationStatus.dismissed
            ? 1 + 7 * (1 - animation.value)
            : 1,
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: animation.status == AnimationStatus.reverse
                  ? [
                      Color.lerp(MoodSelectorBundle.backgroundGradientColors[0], topColors[2], animation.value),
                      Color.lerp(MoodSelectorBundle.backgroundGradientColors[1], bottomColors[1], animation.value),
                    ]
                  : [
                      topColor,
                      bottomColor,
                    ],
            ),
          ),
        ),
      );

  Color get topColor => animation.value < 0.5
      ? Color.lerp(topColors[0], topColors[1], animation.value * 2)
      : Color.lerp(topColors[1], topColors[2], (animation.value - 0.5) * 2);

  Color get bottomColor => Color.lerp(bottomColors[0], bottomColors[1], animation.value);
}
