import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlurFilter extends AnimatedWidget {
  final Animation<double> animation;
  final double blurStrength;
  final Widget child;

  BlurFilter({this.animation, this.blurStrength = 10.0, this.child}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: animation == null ? blurStrength : animation.value * blurStrength,
          sigmaY: animation == null ? blurStrength : animation.value * blurStrength,
        ),
        child: child,
      );
}
