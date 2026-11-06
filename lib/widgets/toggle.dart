import 'dart:ui';

import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Toggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  Toggle({
    @required this.value,
    @required this.onChanged,
  });

  @override
  _ToggleState createState() => _ToggleState();
}

class _ToggleState extends SafeState<Toggle> with SingleTickerProviderStateMixin {
  static const double circleRadius = 12;
  static const double circleOffOpacity = 0.3;
  static const double circleOnOpacity = 0.95;
  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    if (widget.value) {
      toggleOn();
    }
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Toggle oldWidget) {
    if (oldWidget.value != widget.value) {
      toggleState();
    }
    super.didUpdateWidget(oldWidget);
  }

  void toggleState() {
    if (animationController.status == AnimationStatus.forward ||
        animationController.status == AnimationStatus.completed) {
      toggleOff();
    } else {
      toggleOn();
    }
  }

  void toggleOn() => animationController.forward();

  void toggleOff() => animationController.reverse();

  void onTap() => widget.onChanged(!widget.value);

  double get circleOpacity => lerpDouble(circleOffOpacity, circleOnOpacity, animationController.value);

  Widget get background => Container(
        width: circleRadius * 4,
        height: circleRadius * 2,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(circleRadius),
        ),
      );

  Widget get circle => AnimatedBuilder(
        animation: animationController,
        builder: (context, _) => Container(
          transform: Matrix4.translationValues(lerpDouble(0, circleRadius * 2, animationController.value), 0, 0),
          width: circleRadius * 2,
          height: circleRadius * 2,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(circleOpacity),
            borderRadius: BorderRadius.circular(circleRadius),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              background,
              circle,
            ],
          ),
        ),
      );
}
