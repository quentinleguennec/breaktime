import 'dart:math';

import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:slide_container/slide_container.dart';
import 'package:slide_container/slide_container_controller.dart';

class CloseTreatmentSlideContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onSlideStarted;
  final VoidCallback onSlideCompleted;
  final VoidCallback onSlideCanceled;
  final ValueChanged<double> onSlide;
  final SlideContainerController controller;
  final bool shouldPop;

  CloseTreatmentSlideContainer({
    @required this.child,
    this.onSlideStarted,
    this.onSlideCompleted,
    this.onSlideCanceled,
    this.onSlide,
    this.controller,
    this.shouldPop = true,
  });

  @override
  _State createState() => _State();
}

class _State extends BasePresenter<CloseTreatmentSlideContainer> {
  double overlayOpacity = 1.0;

  double get maxSlideDistance => MediaQuery.of(context).size.height;

  double get minSlideDistanceToValidate => maxSlideDistance * 0.5;

  void onSlide(double verticalPosition) {
    setMountedState(() => overlayOpacity = (1.000912 -
            0.1701771 * verticalPosition +
            1.676138 * pow(verticalPosition, 2) -
            3.784127 * pow(verticalPosition, 3))
        .clamp(0.0, 1.0));

    if (widget.onSlide != null) widget.onSlide(verticalPosition);
  }

  void onSlideCompleted() {
    if (widget.onSlideCompleted != null) {
      widget.onSlideCompleted();
    }
    if (widget.shouldPop) {
      pop();
    }
  }

  @override
  Widget build(BuildContext context) => SlideContainer(
        controller: widget.controller,
        slideDirection: SlideContainerDirection.topToBottom,
        onSlide: onSlide,
        onSlideCompleted: onSlideCompleted,
        minDragVelocityForAutoSlide: 600.0,
        minSlideDistanceToValidate: minSlideDistanceToValidate,
        maxSlideDistance: maxSlideDistance,
        autoSlideDuration: const Duration(milliseconds: 300),
        onSlideStarted: widget.onSlideStarted,
        onSlideCanceled: widget.onSlideCanceled,
        onSlideValidated: () => HapticFeedback.mediumImpact(),
        child: Opacity(
          opacity: overlayOpacity,
          child: widget.child,
        ),
      );
}
