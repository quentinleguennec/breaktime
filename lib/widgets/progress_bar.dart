import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedProgressBar extends AnimatedWidget {
  final Animation<double> animation;
  final Color color;
  final StrokeCap strokeCap;
  final Color backgroundColor;
  final Gradient gradient;

  /// length of the bar in pixels.
  final double length;

  /// Width of the bar in pixels.
  final double width;

  AnimatedProgressBar({
    @required this.length,
    this.animation,
    this.width,
    this.color,
    this.strokeCap = StrokeCap.square,
    this.backgroundColor,
    this.gradient,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => Container(
        width: length,
        height: width,
        child: CustomPaint(
          painter: _Painter(
            animation: animation,
            color: color ?? Colors.grey,
            targetLength: length,
            width: width ?? 4.0,
            strokeCap: strokeCap,
            backgroundColor: backgroundColor,
            gradient: gradient,
          ),
        ),
      );
}

class ProgressBar extends StatelessWidget {
  final Color color;
  final StrokeCap strokeCap;
  final Color backgroundColor;
  final Gradient gradient;

  /// length of the bar in pixels.
  final double length;

  /// Width of the bar in pixels.
  final double width;

  /// Starting position between 0.0 (beginning) and 1.0 (end) if not using an animation.
  final double position;

  ProgressBar({
    @required this.length,
    this.position,
    this.width,
    this.color,
    this.strokeCap = StrokeCap.square,
    this.backgroundColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: length,
        height: width,
        child: CustomPaint(
          painter: _Painter(
            color: color ?? Colors.grey,
            targetLength: length,
            width: width ?? 4.0,
            staticPosition: position,
            strokeCap: strokeCap,
            backgroundColor: backgroundColor,
            gradient: gradient,
          ),
        ),
      );
}

class _Painter extends CustomPainter {
  final Animation<double> animation;
  final double staticPosition;
  final Color color;
  final double targetLength;
  final double totalLength;
  final double width;
  final StrokeCap strokeCap;
  final Color backgroundColor;
  final Gradient gradient;

  double get length => animation == null ? staticPosition * totalLength : animation.value * totalLength;

  _Painter({
    @required this.color,
    @required this.targetLength,
    @required this.width,
    this.animation,
    this.staticPosition = 0.0,
    this.strokeCap = StrokeCap.square,
    this.backgroundColor,
    this.gradient,
  })  : totalLength = max(targetLength - width, 0),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor ?? color
      ..shader = gradient?.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = width
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    if (backgroundColor != null) {
      canvas.drawLine(
        Offset(paint.strokeWidth * 0.5, paint.strokeWidth * 0.5),
        Offset(paint.strokeWidth * 0.5 + targetLength, paint.strokeWidth * 0.5),
        paint,
      );
      paint.color = color;
    }

    canvas.drawLine(
      Offset(paint.strokeWidth * 0.5, paint.strokeWidth * 0.5),
      Offset(paint.strokeWidth * 0.5 + length, paint.strokeWidth * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_Painter other) =>
      animation?.value != other.animation?.value ||
      color != other.color ||
      targetLength != other.targetLength ||
      staticPosition != other.staticPosition ||
      width != other.width;
}
