import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:flutter/material.dart';

class ErrorCardLayout extends BasicCardLayout {
  ErrorCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutPlacements(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addNextButton(list);
    addPlacements(list);
    return list;
  }
}
