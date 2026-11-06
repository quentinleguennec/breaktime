import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/widgets/reveal_container.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class CardBackgroundVideoPlayer extends StatefulWidget {
  final PageContext pageContext;
  final VoidCallback onVideoLoaded;

  CardBackgroundVideoPlayer(this.pageContext, {this.onVideoLoaded}) : super(key: UniqueKey());

  @override
  _CardVideoPlayerState createState() => _CardVideoPlayerState();
}

class _CardVideoPlayerState extends SafeState<CardBackgroundVideoPlayer> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> showVideoAnimation;
  VideoPlayerController videoController;
  VoidCallback videoControllerListener;
  bool videoIsReadyToPlay = false;

  bool get shouldPlayVideo => widget.pageContext.visibilityChangedNotifier == null
      ? false
      : widget.pageContext.menuController.isHidden &&
          widget.pageContext.visibilityChangedNotifier.value == CardVisibilityChanged.onScreen;

  @override
  void initState() {
    widget.pageContext.visibilityChangedNotifier?.addListener(onVisibilityChanged);
    widget.pageContext.menuController?.addListener(onVisibilityChanged);

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    showVideoAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.linear));

    if (widget.pageContext.card.background.video.contains("splash")) {
      videoController = VideoPlayerController.asset(widget.pageContext.card.background.video)..setLooping(false);
    } else {
      videoController = VideoPlayerController.network(widget.pageContext.card.background.video)..setLooping(true);
    }

    videoController.initialize().then(
      (_) {
        if (widget.onVideoLoaded != null) widget.onVideoLoaded();
        refreshState();
        animationController.forward().then((_) {
          videoIsReadyToPlay = true;
          if (shouldPlayVideo) {
            playVideo();
          }
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    videoController?.dispose();
    widget.pageContext.visibilityChangedNotifier?.removeListener(onVisibilityChanged);
    widget.pageContext.menuController?.removeListener(onVisibilityChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.visibilityChangedNotifier.removeListener(onVisibilityChanged);
    oldWidget.pageContext.menuController.removeListener(onVisibilityChanged);
    widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);
    widget.pageContext.menuController.addListener(onVisibilityChanged);
  }

  void onVisibilityChanged() {
    if (shouldPlayVideo) {
      if (videoIsReadyToPlay) {
        playVideo();
      }
    } else {
      pauseVideo();
    }
  }

  void playVideo() {
    if (!videoController.value.isPlaying) {
      videoController.play();
      widget.pageContext.cardTimerController?.resume();
      refreshState();
    }
  }

  void pauseVideo() {
    if (videoController.value.isPlaying) {
      videoController.pause();
      widget.pageContext.cardTimerController?.pause();
    }
  }

  Size getVideoTargetSize(BuildContext context) {
    double videoWidth = 0.0;
    double videoHeight = 0.0;
    Size targetBoxSize = MediaQuery.of(context).size;
    targetBoxSize -= Offset(0.0, MediaQuery.of(context).padding.bottom);
    if (videoController?.value?.size != null) {
      if (videoController.value.aspectRatio == 0 || videoController.value.aspectRatio.isNaN) {
        videoWidth = targetBoxSize.width.ceilToDouble();
        videoHeight = targetBoxSize.height.ceilToDouble();
      }

      /// This is to make the video fill the screen without stretching (cuts the biggest side).
      else if (videoController.value.size.width / targetBoxSize.width <=
          videoController.value.size.height / targetBoxSize.height) {
        videoWidth = targetBoxSize.width.ceilToDouble();
        videoHeight = (videoWidth / videoController.value.aspectRatio).ceilToDouble();
      } else {
        videoHeight = targetBoxSize.height.ceilToDouble();
        videoWidth = (videoHeight * videoController.value.aspectRatio).ceilToDouble();
      }
    }
    return Size(videoWidth, videoHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pageContext.card.isAudioCard()) {
      return Container();
    }
    Size targetSize = getVideoTargetSize(context);
    return RevealContainer(
      showVideoAnimation,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          alignment: Alignment.center,
          child: Container(
            width: targetSize.width,
            height: targetSize.height,
            child: VideoPlayer(videoController),
          ),
        ),
      ),
    );
  }
}
