import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/widgets/overlay_video_player_card.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:flutter/material.dart';

class VideoCardLayout extends BasicCardLayout {
  static final String fullScreenVideo = "fullScreenVideo";
  final VoidCallback onActivated;

  VideoCardLayout(
    pageContext,
    animator,
    this.onActivated,
    onVideoLoaded,
    onImageLoaded,
  ) : super(pageContext, animator, onVideoLoaded, onImageLoaded) {
    /// The full screen video uses the background video field in the CMS, so we need to trigger [onVideoLoaded] to allow text placements to appear.
    onVideoLoaded();
  }

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundImage(context, layoutChild, size, positionChild);
    layoutPlacements(context, size, layoutChild, positionChild);
    layoutFullScreenVideo(size, layoutChild, positionChild);
    layoutTimer(context, size, layoutChild, positionChild);
    layoutActiveIngredientIcon(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
  }

  void layoutFullScreenVideo(Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(fullScreenVideo, BoxConstraints.expand(width: size.width, height: size.height));
    positionChild(fullScreenVideo, Offset(0.0, 0.0));
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundImage(list);
    addPlacements(list);
    addFullScreenVideo(list);
    addTimer(list);
    addActiveIngredientIcon(list);
    addNextButton(list);
    return list;
  }

  void addFullScreenVideo(LayoutList list) =>
      list.layout(fullScreenVideo, () => OverlayVideoPlayerCard(pageContext, onActivated));
}
