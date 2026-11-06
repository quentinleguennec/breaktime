import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/story_card_layout.dart';
import 'package:flutter/widgets.dart';

class StoryCard extends BasicCard {
  StoryCard(pageContext) : super(pageContext);

  @override
  BasicCardState createState() => _StoryCardState();
}

class _StoryCardState extends BasicCardState {
  @override
  bool get isCardReady => widget.pageContext.visibilityChangedNotifier.value != CardVisibilityChanged.offScreen;

  Widget buildCardLayout(BasicCard widget, CardAnimator animator) =>
      StoryCardLayout(widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded);
}
