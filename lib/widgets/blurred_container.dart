import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BlurContainer extends StatelessWidget {
  final double blurStrength;
  final Widget child;

  BlurContainer({this.blurStrength = 10.0, this.child});

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          child ?? Container(),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurStrength,
                sigmaY: blurStrength,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      );
}
