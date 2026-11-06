import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The code duplication between [ParallaxBoxWithGlobalPosition] and [ParallaxBoxWithTrueParallax] is
/// annoying but hard to fix because of the static method computeParallaxDisplacement.
class ParallaxBoxWithGlobalPosition extends StatefulWidget {
  static const double parallaxStrength = 0.1;

  final Widget child;
  final ScrollController scrollController;
  final Animation<double> animation;

  static double computeParallaxDisplacement(RenderBox renderBox, BuildContext context) =>
      (renderBox.localToGlobal(Offset.zero).dy +
          renderBox.size.height * 0.5 -
          MediaQuery.of(context).size.height * 0.5) *
      ParallaxBoxWithGlobalPosition.parallaxStrength;

  ParallaxBoxWithGlobalPosition({
    @required this.child,
    @required this.scrollController,
    this.animation,
  });

  @override
  _ParallaxBoxWithGlobalPositionState createState() => _ParallaxBoxWithGlobalPositionState();
}

class _ParallaxBoxWithGlobalPositionState extends SafeState<ParallaxBoxWithGlobalPosition> {
  double yTranslation = 0.0;
  VoidCallback scrollListener;

  @override
  void initState() {
    super.initState();

    /// renderBox is only available after [build] has been called.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      updateParallax(context.findRenderObject());
    });

    scrollListener = () => updateParallax(context.findRenderObject());
    widget.scrollController?.addListener(scrollListener);
    widget.animation?.addListener(refreshState);
  }

  @override
  void didUpdateWidget(ParallaxBoxWithGlobalPosition oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.scrollController?.removeListener(scrollListener);
    widget.scrollController?.addListener(scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(scrollListener);
    widget.animation?.removeListener(refreshState);
    super.dispose();
  }

  void updateParallax(RenderBox renderBox) {
    if (renderBox != null) {
      yTranslation = ParallaxBoxWithGlobalPosition.computeParallaxDisplacement(renderBox, context);
      if (widget.animation == null || widget.animation.isCompleted || widget.animation.isDismissed) {
        refreshState();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.translationValues(0.0, yTranslation, 0.0),
        child: widget.child,
      );
}

class ParallaxBoxWithTrueParallax extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;

  /// In pixels.
  final double parallaxDisplacement;
  final Animation<double> animation;

  ParallaxBoxWithTrueParallax({
    @required this.child,
    @required this.scrollController,
    this.parallaxDisplacement = 250,
    this.animation,
  });

  @override
  _ParallaxBoxWithTrueParallaxState createState() => _ParallaxBoxWithTrueParallaxState();
}

class _ParallaxBoxWithTrueParallaxState extends SafeState<ParallaxBoxWithTrueParallax> {
  double yTranslation = 0.0;
  VoidCallback scrollListener;

  ScrollPosition get scrollPosition => widget.scrollController.hasClients ? widget.scrollController.position : null;

  @override
  void initState() {
    super.initState();

    scrollListener = () => updateParallax();
    widget.scrollController?.addListener(scrollListener);
    widget.animation?.addListener(refreshState);
  }

  @override
  void didUpdateWidget(ParallaxBoxWithTrueParallax oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.scrollController?.removeListener(scrollListener);
    widget.scrollController?.addListener(scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(scrollListener);
    widget.animation?.removeListener(refreshState);
    super.dispose();
  }

  void updateParallax() {
    if (scrollPosition != null && scrollPosition.maxScrollExtent != 0) {
      yTranslation = ((scrollPosition.pixels / scrollPosition.maxScrollExtent)) * widget.parallaxDisplacement;
      if (widget.animation == null || widget.animation.isCompleted || widget.animation.isDismissed) {
        refreshState();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.translationValues(0.0, yTranslation, 0.0),
        child: widget.child,
      );
}

@immutable
class TreatmentListItemRenderBoxDataForAnimation {
  final Treatment treatment;
  final Offset renderBoxPosition;
  final Size renderBoxSize;
  final double parallaxDisplacement;
  final bool isRecommended;

  TreatmentListItemRenderBoxDataForAnimation({
    @required this.renderBoxPosition,
    @required this.renderBoxSize,
    this.treatment,
    this.parallaxDisplacement,
    this.isRecommended = false,
  });
}
