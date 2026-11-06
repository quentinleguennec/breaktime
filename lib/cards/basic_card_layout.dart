import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/widgets/active_ingredient_icon.dart';
import 'package:aebeze/cards/widgets/card_background_image.dart';
import 'package:aebeze/cards/widgets/card_background_video_player.dart';
import 'package:aebeze/cards/widgets/placement_widget.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/buttons/card_timer.dart';
import 'package:aebeze/widgets/card_next_button.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:flutter/material.dart';

abstract class CardMultiChildLayout extends MultiChildLayout {
  final DataCard card;

  CardMultiChildLayout(this.card);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: card.background?.gradient,
          color: card.background?.gradient != null ? null : cardBackgroundColor(card),
        ),
        child: super.build(context),
      );
}

class BasicCardLayout extends CardMultiChildLayout {
  static final String backgroundImage = "backgroundImage";
  static final String backgroundVideo = "backgroundVideo";
  static final String timer = "timer";
  static final String nextButton = "nextArrow";
  static final String activeIngredientIcon = "activeIngredientIcon";
  static final String placement = "placement";
  static const double timerPositionFromTop = 70;
  static const double topElementsPositionFromTop = 22;
  static const double bottomElementsPositionFromBottom = 96;
  final PageContext pageContext;
  final CardAnimator animator;
  final VoidCallback onBackgroundVideoLoaded;
  final VoidCallback onBackgroundImageLoaded;

  BasicCardLayout(
    this.pageContext,
    this.animator,
    this.onBackgroundVideoLoaded,
    this.onBackgroundImageLoaded,
  ) : super(pageContext.card);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundImage(context, layoutChild, size, positionChild);
    layoutBackgroundVideo(context, size, layoutChild, positionChild);
    layoutTimer(context, size, layoutChild, positionChild);
    layoutActiveIngredientIcon(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
    layoutPlacements(context, size, layoutChild, positionChild);
  }

  /// this can control the layer position of the elements added.
  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundImage(list);
    addBackgroundVideo(list);
    addTimer(list);
    addActiveIngredientIcon(list);
    addNextButton(list);
    addPlacements(list);
    return list;
  }

  void layoutBackgroundImage(BuildContext context, LayoutChild layoutChild, Size size, PositionChild positionChild) {
    if (card.hasBackgroundImage()) {
      layoutChild(
        backgroundImage,
        BoxConstraints.expand(
          width: size.width,
          height: size.height,
        ),
      );
      positionChild(backgroundImage, Offset.zero);
    }
  }

  void layoutBackgroundVideo(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    if (card.hasBackgroundVideo()) {
      layoutChild(
        backgroundVideo,
        BoxConstraints.expand(
          width: size.width,
          height: size.height,
        ),
      );
      positionChild(backgroundVideo, Offset.zero);
    }
  }

  void layoutTimer(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    if (card.hasTimer()) {
      layoutChild(timer, BoxConstraints.tightFor());
      positionChild(
        timer,
        Offset(
          0.0,
          0.5 * MediaQuery.of(context).padding.top + timerPositionFromTop,
        ),
      );
    }
  }

  void layoutActiveIngredientIcon(
      BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    if (!card.isStartCard() && !card.isEndCard()) {
      layoutChild(activeIngredientIcon, BoxConstraints.tightFor());
      positionChild(
        activeIngredientIcon,
        Offset(
          // Compensate for image padding.
          hugePadding - 8.0,
          0.5 * MediaQuery.of(context).padding.top + topElementsPositionFromTop,
        ),
      );
    }
  }

  void layoutPlacements(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(
      placement,
      BoxConstraints.tightFor(
        width: size.width,
        height: size.height - MediaQuery.of(context).padding.bottom,
      ),
    );
    positionChild(placement, Offset.zero);
  }

  void layoutNextArrow(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    Size buttonSize = layoutChild(nextButton, BoxConstraints.tightFor());
    positionChild(
      nextButton,
      Offset(
        hugePadding,
        size.height - MediaQuery.of(context).padding.bottom - buttonSize.height - bottomElementsPositionFromBottom,
      ),
    );
  }

  void addBackgroundImage(LayoutList list) => list.layout(
      backgroundImage,
      () => CardBackgroundImage(
            card.background,
            onImageLoaded: onBackgroundImageLoaded,
          ),
      when: card.hasBackgroundImage());

  void addBackgroundVideo(LayoutList list) => list.layout(
      backgroundVideo,
      () => CardBackgroundVideoPlayer(
            pageContext,
            onVideoLoaded: onBackgroundVideoLoaded,
          ),
      when: card.hasBackgroundVideo());

  void addTimer(LayoutList list) => list.layout(timer, () => CardTimer(pageContext), when: card.hasTimer());

  void addActiveIngredientIcon(LayoutList list) => list.layout(
        activeIngredientIcon,
        () => ActiveIngredientIcon(
          cardActiveIngredients: pageContext.card.activeIngredients,
          treatmentName: pageContext.treatment.name,
        ),
        when: !card.isStartCard() && !card.isEndCard(),
      );

  void addPlacements(LayoutList list) =>
      list.layout(placement, () => PlacementWidget.fromCard(card, animation: animator.placementsAnimation));

  void addNextButton(LayoutList list) => list.layout(
        nextButton,
        () => CardNextButton(pageContext: pageContext),
      );
}
