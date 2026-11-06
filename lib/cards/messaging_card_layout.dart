import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/widgets/overlay_messaging_card.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:flutter/material.dart';

class MessagingCardLayout extends BasicCardLayout {
  static final String messagingCard = "messagingCard";
  final ValueChanged<bool> onEditMessageChanged;
  final bool isEditingMessage;

  MessagingCardLayout(
      pageContext, animator, onVideoLoaded, onImageLoaded, this.isEditingMessage, this.onEditMessageChanged)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundImage(context, layoutChild, size, positionChild);
    _layoutMessagingCard(size, layoutChild, positionChild);
    layoutTimer(context, size, layoutChild, positionChild);
    if (!isEditingMessage) layoutActiveIngredientIcon(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
  }

  void _layoutMessagingCard(Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(messagingCard, BoxConstraints.expand(width: size.width, height: size.height));
    positionChild(messagingCard, Offset.zero);
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundImage(list);
    addMessagingCard(list);
    addTimer(list);
    if (!isEditingMessage) addActiveIngredientIcon(list);
    addNextButton(list);
    return list;
  }

  void addMessagingCard(LayoutList list) {
    list.layout(messagingCard, () => OverlayMessagingCard(pageContext, onEditMessageChanged));
  }
}
