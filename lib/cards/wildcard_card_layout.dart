import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/widgets/overlay_wildcard_card.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:flutter/material.dart';

class WildcardCardLayout extends BasicCardLayout {
  static final String wildcardOverlay = "wildcardOverlay";
  final VoidCallback onWildcardOverlayDismissed;
  final bool isOverlayDismissed;

  WildcardCardLayout(
      pageContext, animator, this.onWildcardOverlayDismissed, this.isOverlayDismissed, onVideoLoaded, onImageLoaded)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    if (isOverlayDismissed) layoutBackgroundImage(context, layoutChild, size, positionChild);
    if (isOverlayDismissed) layoutBackgroundVideo(context, size, layoutChild, positionChild);
    if (isOverlayDismissed) layoutPlacements(context, size, layoutChild, positionChild);
    if (isOverlayDismissed) layoutTimer(context, size, layoutChild, positionChild);
    if (!isOverlayDismissed) layoutWildcardOverlay(size, layoutChild, positionChild);
    layoutActiveIngredientIcon(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
  }

  void layoutWildcardOverlay(Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(wildcardOverlay, BoxConstraints.expand(width: size.width, height: size.height));
    positionChild(wildcardOverlay, Offset(0.0, 0.0));
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    if (isOverlayDismissed) addBackgroundImage(list);
    if (isOverlayDismissed) addBackgroundVideo(list);
    if (isOverlayDismissed) addPlacements(list);
    if (isOverlayDismissed) addTimer(list);
    if (!isOverlayDismissed) addWildcardOverlay(list);
    addActiveIngredientIcon(list);
    addNextButton(list);
    return list;
  }

  void addWildcardOverlay(LayoutList list) =>
      list.layout(wildcardOverlay, () => OverlayWildcardCard(pageContext, onWildcardOverlayDismissed));
}
