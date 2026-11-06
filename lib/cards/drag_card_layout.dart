import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/widgets/drag_card_content.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:flutter/material.dart';

class DragCardLayout extends BasicCardLayout {
  static final String dragCardContent = "dragCardContent";

  DragCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundImage(context, layoutChild, size, positionChild);
    layoutBackgroundVideo(context, size, layoutChild, positionChild);
    layoutDraggableContent(size, layoutChild, positionChild);
    layoutTimer(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
    layoutActiveIngredientIcon(context, size, layoutChild, positionChild);
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundImage(list);
    addBackgroundVideo(list);
    addDragCardContent(list);
    addTimer(list);
    addActiveIngredientIcon(list);
    addNextButton(list);
    return list;
  }

  void addDragCardContent(LayoutList list) {
    list.layout(dragCardContent, () => DragCardContent(card));
  }

  void layoutDraggableContent(Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(dragCardContent, BoxConstraints.tightFor(width: size.width, height: size.height));
    positionChild(dragCardContent, Offset.zero);
  }
}
