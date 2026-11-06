import 'package:aebeze/dashboard/treatment_animated_image.dart';
import 'package:aebeze/dashboard/treatment_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InflateAnimationOverlay extends AnimatedWidget {
  final Animation inflateAnimation;
  final Animation opacityAnimation;
  final Animation textOpacityAnimation;
  final TreatmentListItemRenderBoxDataForAnimation boxData;

  InflateAnimationOverlay({
    @required this.inflateAnimation,
    @required this.opacityAnimation,
    @required this.textOpacityAnimation,
    @required this.boxData,
  }) : super(listenable: Listenable.merge([inflateAnimation, opacityAnimation, textOpacityAnimation]));

  @override
  Widget build(BuildContext context) {
    final Offset boxPosition = boxData.renderBoxPosition;
    final Size boxSize = boxData.renderBoxSize;
    final inflateValue = inflateAnimation.value;
    final Size screenSize = MediaQuery.of(context).size;
    return Positioned(
      left: boxPosition.dx * (1.0 - inflateValue),
      width: boxSize.width + inflateValue * (screenSize.width - boxSize.width),
      top: boxPosition.dy * (1.0 - inflateValue),
      height: boxSize.height + inflateValue * (screenSize.height - boxSize.height),
      child: Opacity(
        opacity: 1 - opacityAnimation.value,
        child: Material(
          color: Colors.transparent,
          child: TreatmentListItemInflateAnimatedWidget(
            animationData: boxData,
            screenWidth: MediaQuery.of(context).size.width,
            animation: textOpacityAnimation,
          ),
        ),
      ),
    );
  }
}
