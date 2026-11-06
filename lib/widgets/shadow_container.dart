import 'package:flutter/widgets.dart';

class ShadowContainer extends Container {
  ShadowContainer({
    Key key,
    alignment,
    padding,
    double width,
    double height,
    BoxConstraints constraints,
    margin,
    transform,
    child,
    shadowBlurRadius = 20,
    shadowSpreadRadius = 30,
  }) : super(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x90000000),
                blurRadius: shadowBlurRadius,
                spreadRadius: shadowSpreadRadius,
              ),
            ],
          ),
          key: key,
          alignment: alignment,
          padding: padding,
          width: width,
          height: height,
          constraints: constraints,
          margin: margin,
          transform: transform,
          child: child,
        );
}
