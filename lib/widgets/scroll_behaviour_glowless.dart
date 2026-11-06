import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// [ScrollBehavior] without the over-scroll glow on Android.
class ScrollBehaviorGlowless extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;
}
