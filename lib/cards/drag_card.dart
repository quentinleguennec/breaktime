import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/drag_card_layout.dart';
import 'package:flutter/widgets.dart';

class DragCard extends BasicCard {
  DragCard(PageContext pageContext) : super(pageContext);

  @override
  BasicCardState createState() => _DragCardState();
}

class _DragCardState extends BasicCardState {
  Widget buildCardLayout(BasicCard widget, CardAnimator animator) =>
      DragCardLayout(widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded);
}
