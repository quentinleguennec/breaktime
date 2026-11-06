import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum SwipeDirection {
  topToBottom,
  bottomToTop,
}

/// Use this to detect a vertical swipe gesture.
class SwipeGestureDetector extends StatefulWidget {
  final ValueChanged<SwipeDirection> onSwipeValidated;
  final Widget child;

  /// If a swipe is done faster than this value and for a distance bigger than [minDistanceForVelocity] the swipe will be validated.
  ///
  /// In px/s.
  final double minVelocityToValidate;

  /// To prevent fast horizontal swipes to trigger the callback we add a minimum vertical distance to validate the velocity trigger.
  ///
  /// In px/s.
  final double minDistanceForVelocity;

  /// If a swipe distance is bigger than this value the swipe will be validated.
  ///
  /// In px.
  final double minDistanceToValidate;

  SwipeGestureDetector({
    this.onSwipeValidated,
    this.child,
    this.minVelocityToValidate = 600.0,
    this.minDistanceForVelocity = 50.0,
    this.minDistanceToValidate = 200.0,
  });

  @override
  _State createState() => _State();
}

class _State extends State<SwipeGestureDetector> {
  double dragValue = 0.0;
  bool didSwipe = false;

  double get minVelocityToValidate => widget.minVelocityToValidate;

  double get minDistanceForVelocity => widget.minDistanceForVelocity;

  double get minDistanceToValidate => widget.minDistanceToValidate;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onVerticalDragStart: (DragStartDetails details) {
          dragValue = 0.0;
          didSwipe = false;
        },
        onVerticalDragUpdate: (DragUpdateDetails details) => handleDragUpdate(details),
        onVerticalDragEnd: (DragEndDetails details) {
          if (didSwipe) return;
          if (details.velocity.pixelsPerSecond.dy < -minVelocityToValidate && dragValue < -minDistanceForVelocity) {
            widget.onSwipeValidated(SwipeDirection.bottomToTop);
          } else if (details.velocity.pixelsPerSecond.dy > minVelocityToValidate &&
              dragValue > minDistanceForVelocity) {
            widget.onSwipeValidated(SwipeDirection.topToBottom);
          }
        },
        child: widget.child,
      );

  void handleDragUpdate(DragUpdateDetails details) {
    if (didSwipe) return;
    dragValue += details.delta.dy;
    if (dragValue < -minDistanceToValidate) {
      widget.onSwipeValidated(SwipeDirection.bottomToTop);
      didSwipe = true;
    } else if (dragValue > minDistanceToValidate) {
      widget.onSwipeValidated(SwipeDirection.topToBottom);
      didSwipe = true;
    }
  }
}
