import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class DragCircle extends StatefulWidget {
  static const double circleRadius = 130.0;
  static const double circleBoxSize = circleRadius + 24.0;
  static const double additionalBlurredCircleRadius = 14;
  static const double additionalBlurredCircleMaxOffsetRatio = 0.15;
  static const double indicatorsContainerSize = 25;
  static const double indicatorsVerticalPaddingHeightRatio = 0.65;

  final int startingPointIndex;
  final ValueChanged<PositionChangedData> onPositionChanged;
  final VoidCallback onTouched;
  final ValueChanged<PositionChangedData> onReleased;

  DragCircle({
    this.startingPointIndex,
    this.onPositionChanged,
    this.onTouched,
    this.onReleased,
  });

  @override
  _DragCircleState createState() => _DragCircleState();
}

class _DragCircleState extends SafeState<DragCircle> with TickerProviderStateMixin {
  Offset dragValue = Offset.zero;
  Offset dragTarget = Offset.zero;
  Ticker followFingerTicker;
  bool isDragging = false;
  bool isFingerDown = false;
  AnimationController animationController;
  Animation scaleAnimation;
  AnimationController pulseScaleAnimationController;
  Animation pulseScaleAnimation;
  List<Offset> _pointsPositions;
  Offset fingerDownGlobalPosition = Offset.zero;
  Offset dragStartGlobalPosition = Offset.zero;
  Offset fingerPositionFromCircleCenter = Offset.zero;

  Offset get startingPosition => MediaQuery.of(context).size.center(Offset.zero);

  double get usedHeight => (1 - DragCircle.indicatorsVerticalPaddingHeightRatio) * MediaQuery.of(context).size.height;

  double get yOffset => MediaQuery.of(context).size.height * 0.07;

  double get spaceBetweenPoints => (usedHeight - Moods.count * DragCircle.indicatorsContainerSize) / (Moods.count - 1);

  double get normalizedDistanceToFocusedPoint =>
      ((dragValue.dy - closestPointOffset.dy).abs() / (spaceBetweenPoints * 0.5)).clamp(0.0, 1.0);

  double get maxDragCircleOffsetValue => (usedHeight - DragCircle.indicatorsContainerSize) * 0.5;

  int get closestPointIndex {
    int index =
        pointsPositions.indexWhere((point) => (point.dy - dragValue.dy).abs() <= usedHeight / (Moods.count + 1));
    if (index == -1) {
      index = dragValue.dy >= pointsPositions.last.dy ? pointsPositions.length - 1 : 0;
    }

    return index;
  }

  Offset get closestPointOffset => pointsPositions[closestPointIndex];

  List<Offset> get pointsPositions {
    if (_pointsPositions == null) {
      double height = MediaQuery.of(context).size.height;
      double verticalPadding = (height - usedHeight) * 0.5;
      _pointsPositions = List<Offset>.generate(Moods.count, (index) {
        double y = (verticalPadding + (index + 0.5) * DragCircle.indicatorsContainerSize + index * spaceBetweenPoints) -
            height * 0.5;
        return Offset(0, y);
      });
    }
    return _pointsPositions;
  }

  Color get circleColor => Colors.white;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..addListener(refreshState);
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(animationController);
    pulseScaleAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..addListener(refreshState);
    pulseScaleAnimation = Tween<double>(begin: 0.90, end: 1.1).animate(pulseScaleAnimationController);
    pulseScaleAnimationController.repeat(reverse: true);

    followFingerTicker = createTicker((_) {
      if ((dragValue - dragTarget).distanceSquared <= 1.0) {
        dragTarget = dragValue;
        if (!isDragging) {
          followFingerTicker.stop();
        }
      } else {
        // This dampen the drag movement (acts like a spring, the farther from the finger position the faster it moves toward it).
        dragTarget += (dragValue - dragTarget) / 3.0;
      }
      if (widget.onPositionChanged != null) {
        widget.onPositionChanged(PositionChangedData(
          dragTarget,
          closestPointIndex,
          normalizedDistanceToFocusedPoint,
          circleColor,
        ));
      }
      refreshState();
    });

    if (widget.startingPointIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dragValue = pointsPositions[widget.startingPointIndex];
        followFingerTicker.start();
      });
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    pulseScaleAnimationController?.dispose();
    followFingerTicker?.dispose();
    super.dispose();
  }

  void onDragStart(final DragStartDetails details) {
    isDragging = true;
    pulseScaleAnimationController.stop();
    dragStartGlobalPosition = details.globalPosition;
    onFingerDown(details.globalPosition);
    if (followFingerTicker.isActive) {
      followFingerTicker.stop();
    }
    followFingerTicker.start();
  }

  void onDragUpdate(final DragUpdateDetails details) {
    Offset rawDragValue = details.globalPosition -
        startingPosition +
        (fingerDownGlobalPosition - dragStartGlobalPosition) -
        fingerPositionFromCircleCenter;
    updateDragValueVerticalOnly(rawDragValue);
  }

  void onDragEnd() {
    isDragging = false;
    pulseScaleAnimationController.repeat(reverse: true);
    onFingerUp();
  }

  void onFingerDown(Offset globalPosition) {
    if (!isFingerDown) {
      isFingerDown = true;
      fingerDownGlobalPosition = globalPosition;
      fingerPositionFromCircleCenter = globalPosition - startingPosition - dragValue;
      if (widget.onTouched != null) widget.onTouched();
      animationController.forward();
    }
  }

  void onFingerUp() {
    isFingerDown = false;
    dragValue = closestPointOffset;
    if (widget.onReleased != null)
      widget.onReleased(PositionChangedData(
        dragTarget,
        closestPointIndex,
        normalizedDistanceToFocusedPoint,
        circleColor,
      ));
    animationController.reverse();
  }

  void updateDragValueVerticalOnly(final Offset rawDragValue) {
    final double verticalMovement = rawDragValue.dy.abs();

    Offset newDragValue = rawDragValue;

    // Check the circle wouldn't go out of screen vertically.
    if (verticalMovement > maxDragCircleOffsetValue) {
      // The movement would bring the circle out of the bounding box, clamp the value to the limit of the screen.
      final double yOffsetToEdge = rawDragValue.dy.sign * maxDragCircleOffsetValue;
      newDragValue = Offset(newDragValue.dx, yOffsetToEdge);
    }

    dragValue = Offset(0, newDragValue.dy);
  }

  @override
  Widget build(BuildContext context) => Transform(
        transform: Matrix4.translationValues(dragTarget.dx, dragTarget.dy + yOffset, 0.0),
        origin: Offset(DragCircle.circleBoxSize, DragCircle.circleBoxSize),
        alignment: Alignment.center,
        child: GestureDetector(
          // Hijack drag gesture to prevent PageView scrolling.
          onHorizontalDragStart: (_) => {},
          onTapDown: (details) => onFingerDown(details.globalPosition),
          onTapUp: (_) => onFingerUp(),
          onVerticalDragStart: onDragStart,
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: (_) => onDragEnd(),
          onVerticalDragCancel: () => onDragEnd(),
          child: Transform.scale(
            scale: scaleAnimation.value * pulseScaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: DragCircle.circleBoxSize,
                  width: DragCircle.circleBoxSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 24,
                        offset: Offset(0, -dragTarget.dy * DragCircle.additionalBlurredCircleMaxOffsetRatio),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

@immutable
class PositionChangedData {
  final Offset circleOffset;
  final int focusedPointIndex;
  final double normalizedDistanceToFocusedPoint;
  final Color circleColor;

  PositionChangedData(
    this.circleOffset,
    this.focusedPointIndex,
    this.normalizedDistanceToFocusedPoint,
    this.circleColor,
  );
}
