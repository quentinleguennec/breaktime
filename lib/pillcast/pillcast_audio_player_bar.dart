import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/pillcast/pillcast_audio_player.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class PillcastAudioPlayerBar extends StatefulWidget {
  static const double height = 88;
  final PillcastAudioPlayer audioPlayer;

  const PillcastAudioPlayerBar({this.audioPlayer});

  @override
  _PillcastAudioPlayerBarState createState() => _PillcastAudioPlayerBarState();
}

class _PillcastAudioPlayerBarState extends BasePresenter<PillcastAudioPlayerBar> {
  PillcastAudioPlayer get audioPlayer => widget.audioPlayer;

  Widget get previousTrackButton => BasicIconButton(
        quarterTurns: 2,
        width: defaultIconTapSize,
        height: defaultIconTapSize,
        icon: Image.asset(
          Assets.pillcastSkipButton,
          width: defaultPadding,
          color: Colors.white,
        ),
        onPressed: () => audioPlayer.playPrevious(),
      );

  Widget get playButton => BasicIconButton(
        width: defaultIconTapSize,
        height: defaultIconTapSize,
        icon: Image.asset(
          audioPlayer.state.isPlaying ? Assets.pillcastPauseButton : Assets.pillcastPlayButton,
          width: defaultPadding,
          color: Colors.white,
        ),
        onPressed: () {
          if (audioPlayer.state.isPlaying) {
            audioPlayer.pause();
          } else {
            audioPlayer.playCurrent();
          }
        },
      );

  Widget get nextTrackButton => BasicIconButton(
        width: defaultIconTapSize,
        height: defaultIconTapSize,
        icon: Image.asset(
          Assets.pillcastSkipButton,
          width: defaultPadding,
          color: Colors.white,
        ),
        onPressed: () => audioPlayer.playNext(),
      );

  Widget get movingText => Marquee(
        text: audioPlayer?.state?.trackPlaying?.name ?? "",
        style: AppTextStyles.h6ZirkonRegular.copyWith(color: AppColors.pillcastPlayerText),
        scrollAxis: Axis.horizontal,
        blankSpace: MediaQuery.of(context).size.width,
        velocity: 80,
        pauseAfterRound: Duration(seconds: 1),
        startPadding: 10,
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.linear,
      );

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: audioPlayer.stream,
        builder: (BuildContext context, _) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          height: PillcastAudioPlayerBar.height + MediaQuery.of(context).padding.bottom,
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Visibility(
                visible: audioPlayer.state.isInitialized,
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: movingText,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48, right: 48, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    previousTrackButton,
                    playButton,
                    nextTrackButton,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
