import 'dart:math';

import 'package:aebeze/assets.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressLoader extends StatefulWidget {
  final Color color;

  ProgressLoader({this.color = Colors.white});

  _ProgressLoaderState createState() => _ProgressLoaderState();
}

class _ProgressLoaderState extends SafeState<ProgressLoader> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    final CurvedAnimation curve = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(refreshState)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) controller.forward(from: 0.0);
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 24.0,
        height: 24.0,
        child: Center(
            child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(animation.value * 2 * pi),
                child: Image.asset(
                  Assets.headerBadge,
                  color: widget.color,
                  width: 24.0,
                  height: 24.0,
                ))),
      );
}
