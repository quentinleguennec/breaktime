import 'dart:ui';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/widgets/card_instruction_button.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/buttons/card_timer.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class OverlayVideoPlayerCard extends StatefulWidget {
  final PageContext pageContext;
  final VoidCallback onActivated;

  OverlayVideoPlayerCard(this.pageContext, this.onActivated);

  @override
  _State createState() => _State();
}

class _State extends SafeState<OverlayVideoPlayerCard> with SingleTickerProviderStateMixin {
  VideoPlayerController videoController;
  AnimationController soundFadeController;
  bool isStarted = false;
  bool isResumeInstruction = false;
  int fingersOnScreen = 0;

  DataCard get card => widget.pageContext.card;

  String get fileUrl => card.background.video;

  @override
  void initState() {
    widget.pageContext.visibilityChangedNotifier?.addListener(onVisibilityChanged);

    soundFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        if (isStarted &&
            (soundFadeController.status == AnimationStatus.forward ||
                soundFadeController.status == AnimationStatus.reverse)) {
          videoController.setVolume(soundFadeController.value);
          refreshState();
        }
      })
      ..addStatusListener((status) {
        if (!isStarted) return;
        if (soundFadeController.status == AnimationStatus.dismissed) {
          videoController.setVolume(0.0);
          refreshState();
        }
        if (soundFadeController.status == AnimationStatus.completed) {
          videoController.setVolume(1.0);
          refreshState();
        }
      });

    videoController = VideoPlayerController.network(fileUrl)
      ..setLooping(widget.pageContext.card.isVideoLooping)
      ..setVolume(0.0)
      ..initialize();
    super.initState();
  }

  @override
  void dispose() {
    widget.pageContext.visibilityChangedNotifier?.removeListener(onVisibilityChanged);
    videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.visibilityChangedNotifier?.removeListener(onVisibilityChanged);
    widget.pageContext.visibilityChangedNotifier?.addListener(onVisibilityChanged);
  }

  void onVisibilityChanged() {
    if (!isStarted) return;
    pause();
  }

  void play() {
    if (!videoController.value.isPlaying) {
      videoController.play();
      widget.pageContext.cardTimerController?.resume();
      soundFadeController.forward().then((_) => isResumeInstruction = true);
      HapticFeedback.mediumImpact();
    }
  }

  void pause() {
    soundFadeController.reverse().then((_) {
      widget.pageContext.cardTimerController?.pause();
      videoController.pause();
    });
  }

  Widget get instructionText => Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: BasicCardLayout.bottomElementsPositionFromBottom, left: hugePadding),
          child: CardInstructionButton(
            text: localize(
              context,
              isResumeInstruction ? "card_menu_instruction_hold_to_resume" : "card_menu_instruction_hold_to_play",
            ).toUpperCase(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) {
          fingersOnScreen++;
          if (!isStarted) {
            setMountedState(() => isStarted = true);
            widget.onActivated();
            // For some reason the position when the video is over is not the same as the reported duration.
          }
          // Uncomment to have video restart when the card is pressed again.
//          else if (videoController?.value != null &&
//              videoController.value.duration != null &&
//              videoController.value.position != null &&
//              videoController.value.duration - videoController.value.position < const Duration(milliseconds: 500)) {
//            videoController.seekTo(Duration.zero);
//            widget.pageContext.cardTimerController?.reset();
//          }
          play();
        },
        onPointerUp: (_) {
          fingersOnScreen--;
          if (isStarted && fingersOnScreen == 0) {
            pause();
          }
        },
        child: Container(
          constraints: BoxConstraints.expand(),
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              if (widget.pageContext.cardTimerController.status != TimerStatus.completed) instructionText,
              Opacity(
                opacity: soundFadeController.value,
                child: !isStarted
                    ? Container()
                    : card.isVideoFullscreen || card.audioFile != null
                        ? _VideoPlayerFullScreen(videoController)
                        : _VideoPlayerWithOverlay(videoController),
              ),
            ],
          ),
        ),
      );
}

class _VideoPlayerWithOverlay extends StatelessWidget {
  final VideoPlayerController videoController;

  static const double _overlayOpacity = 0.8;

  _VideoPlayerWithOverlay(this.videoController);

  bool get isAspectRatioReady => videoController?.value?.size != null && videoController?.value?.size != Size.zero;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Opacity(opacity: _overlayOpacity, child: Container(color: Colors.black)),
          Container(
            child: Center(
              child: AspectRatio(
                aspectRatio: !isAspectRatioReady ? 9 / 16 : videoController.value.aspectRatio,
                child: !isAspectRatioReady ? Container() : VideoPlayer(videoController),
              ),
            ),
          ),
        ],
      );
}

class _VideoPlayerFullScreen extends StatelessWidget {
  final VideoPlayerController videoController;

  _VideoPlayerFullScreen(this.videoController);

  Size getVideoTargetSize(BuildContext context) {
    double videoWidth = 0.0;
    double videoHeight = 0.0;
    Size targetBoxSize = MediaQuery.of(context).size;
    targetBoxSize -= Offset(0.0, MediaQuery.of(context).padding.bottom);
    // This additionalPadding is to reduce black bars on Android (they are added by the plugin and cannot be removed).
    // Remove additionalPadding when the Video player doesn't add the black bars anymore.
    double additionalPadding = Theme.of(context).platform == TargetPlatform.android ? defaultPadding : 0.0;
    if (videoController?.value?.size != null) {
      /// This is to make the video fill the screen without stretching (cuts the biggest side).
      if (videoController.value.size.width / targetBoxSize.width <=
          videoController.value.size.height / targetBoxSize.height) {
        videoWidth = targetBoxSize.width.ceilToDouble() + additionalPadding;
        videoHeight = (videoWidth / videoController.value.aspectRatio).ceilToDouble();
      } else {
        videoHeight = targetBoxSize.height.ceilToDouble() + additionalPadding;
        videoWidth = (videoHeight * videoController.value.aspectRatio).ceilToDouble();
      }
    }
    return Size(videoWidth, videoHeight);
  }

  @override
  Widget build(BuildContext context) {
    Size targetSize = getVideoTargetSize(context);
    return ClipRect(
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
    );
  }
}
