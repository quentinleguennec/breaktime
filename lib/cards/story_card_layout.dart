import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/widgets/story_progress.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/reveal_network_image.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class StoryCardLayout extends BasicCardLayout {
  static final String storyImage = "storyImage";
  static final String storyContent = "storyContent";
  static final String storyProgress = "storyProgress";

  StoryCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundImage(context, layoutChild, size, positionChild);
    _layoutStoryCard(size, layoutChild, positionChild, context);
    layoutActiveIngredientIcon(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
  }

  void _layoutStoryCard(Size size, LayoutChild layoutChild, PositionChild positionChild, BuildContext context) {
    layoutChild(storyProgress, BoxConstraints.expand(width: size.width, height: 24.0));
    double yOffset = 0.5 * MediaQuery.of(context).padding.top + BasicCardLayout.timerPositionFromTop;
    positionChild(storyProgress, Offset(0.0, yOffset));

    if (card.storyImage != null) {
      layoutChild(storyImage, BoxConstraints.expand(width: size.width, height: 250.0));
      positionChild(storyImage, Offset(0.0, yOffset + 32.0));
    }

    layoutChild(storyContent, BoxConstraints.expand(width: size.width, height: size.height));
    positionChild(storyContent, Offset(0.0, yOffset + 32.0 + 250.0));
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundImage(list);
    addProgress(list);
    addImage(list);
    addContent(list);
    addActiveIngredientIcon(list);
    addNextButton(list);
    return list;
  }

  void addContent(LayoutList list) {
    Color color = card.storyTextColor == null ? bestFontColorForCard(card) : stringToColor(card.storyTextColor);
    list.layout(
      storyContent,
      () => animator.placementRevealAnimation(
        Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: TextScaled(
            card.storyContent,
            style: AppTextStyles.bodyLight.copyWith(color: color),
          ),
        ),
      ),
    );
  }

  void addImage(LayoutList list) {
    if (card.storyImage != null) {
      list.layout(
          storyImage,
          () => RevealNetworkImage(
                imageUrl: card.storyImage,
                backgroundColor: cardBackgroundColor(card),
              ));
    }
  }

  void addProgress(LayoutList list) {
    list.layout(storyProgress, () => StoryProgress(card, animator));
  }
}
