import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/shadow_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DragContainer extends StatefulWidget {
  final ValueGetter<Widget> childBuilder;
  final VoidCallback onTap;
  final double cardWidthRatio;
  final double cardHeightRatio;
  final double dragHeightPadding;

  DragContainer(this.childBuilder, this.onTap, this.cardWidthRatio, this.cardHeightRatio,
      {this.dragHeightPadding = 100.0});

  @override
  _DragContainerState createState() => _DragContainerState();
}

/// TODO probably more efficient to create animated widget and use animation when drag ends.
class _DragContainerState extends SafeState<DragContainer> with SingleTickerProviderStateMixin {
  /// This coefficient was empirically tested to look good.
  final double empiricalRotateCoefficient = 0.0015;

  bool isDragging = false;
  Offset dragValue = Offset.zero;
  Offset fingerDownPosition;
  Animation<Offset> animation;
  AnimationController controller;

  @override
  initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    animation = Tween(begin: Offset.zero, end: Offset.zero).animate(controller)..addListener(() => refreshState());
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, size) => Center(
          child: dragContainer(
            size.biggest,
            ShadowContainer(
              width: size.maxWidth * widget.cardWidthRatio,
              height: size.maxHeight * widget.cardHeightRatio,
              child: widget.childBuilder(),
            ),
          ),
        ),
      );

  Widget dragContainer(Size screenSize, Widget child) {
    return Transform(
      transform: getDragContainerTransform(),
      alignment: Alignment.center,
      child: GestureDetector(
        // We cannot use Pan for this because HorizontalDrag and VerticalDrag will always consume the Pan gesture before it's called.
        // Because of the Swipe Card having a HorizontalDrag detector the Pan on this container would not be called for horizontal gestures.
        onHorizontalDragStart: handleDragStart,
        onHorizontalDragUpdate: (dragDetails) => handleDragUpdate(screenSize, dragDetails),
        onHorizontalDragEnd: handleDragEnd,
        onVerticalDragStart: handleDragStart,
        onVerticalDragUpdate: (dragDetails) => handleDragUpdate(screenSize, dragDetails),
        onVerticalDragEnd: handleDragEnd,
        onTapDown: (_) => HapticFeedback.mediumImpact(),
        onTap: widget.onTap,
        child: child,
      ),
    );
  }

  void handleDragStart(DragStartDetails details) {
    dragValue = Offset.zero;
    fingerDownPosition = details.globalPosition;
    setMountedState(() => isDragging = true);
  }

  void handleDragUpdate(Size screenSize, DragUpdateDetails details) {
    Offset rawDragValue = details.globalPosition - fingerDownPosition;
    updateDragValue(screenSize, rawDragValue);
    refreshState();
  }

  void handleDragEnd(DragEndDetails details) {
    runAnimation(dragValue);
    setMountedState(() => isDragging = false);
  }

  Matrix4 getDragContainerTransform() => isDragging ? computeManualTransformMatrix() : computeAnimatedTransformMatrix();

  void updateDragValue(Size screenSize, Offset rawDragValue) {
    double horizontalMovement = rawDragValue.dx.abs();
    double verticalMovement = rawDragValue.dy.abs();
    double halfCardWidth = (screenSize.width * widget.cardWidthRatio) / 2.0;
    double halfCardHeight = (screenSize.height * widget.cardHeightRatio) / 2.0;
    double halfScreenWidth = screenSize.width / 2.0;
    double halfScreenHeight = screenSize.height / 2.0 - widget.dragHeightPadding;
    Offset newDragValue = rawDragValue;

    // Check the card wouldn't go out of screen horizontally.
    if (horizontalMovement + halfCardWidth > halfScreenWidth) {
      // The movement would bring the card out of the screen, clamp the value to the limit of the screen.
      double xOffsetToEdge = rawDragValue.dx.sign * (halfScreenWidth - halfCardWidth);
      newDragValue = Offset(xOffsetToEdge, newDragValue.dy);
    }

    // Check the card wouldn't go out of screen vertically.
    if (verticalMovement + halfCardHeight > halfScreenHeight) {
      // The movement would bring the card out of the screen, clamp the value to the limit of the screen.
      double yOffsetToEdge = rawDragValue.dy.sign * (halfScreenHeight - halfCardHeight);
      newDragValue = Offset(newDragValue.dx, yOffsetToEdge);
    }

    dragValue = newDragValue;
  }

  void runAnimation(Offset fromPosition) {
    animation = Tween(begin: fromPosition, end: Offset.zero).animate(controller)..addListener(() => refreshState());
    controller.reset();
    controller.forward();
  }

  Matrix4 computeManualTransformMatrix() {
    return Matrix4.translationValues(dragValue.dx, dragValue.dy, 0.0)
      ..rotateZ(dragValue.dx * empiricalRotateCoefficient);
  }

  Matrix4 computeAnimatedTransformMatrix() {
    return Matrix4.translationValues(animation.value.dx, animation.value.dy, 0.0)
      ..rotateZ(animation.value.dx * empiricalRotateCoefficient);
  }
}
