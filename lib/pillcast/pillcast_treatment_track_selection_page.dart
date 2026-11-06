import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/pillcast/pillcast_audio_player.dart';
import 'package:aebeze/pillcast/pillcast_audio_player_bar.dart';
import 'package:aebeze/pillcast/widgets/page_background.dart';
import 'package:aebeze/pillcast/widgets/treatment_sliver_app_bar.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PillcastTreatmentTrackSelectionPage extends PopupRoute<Null> {
  final PillcastAudioTreatment treatment;
  final PillcastAudioPlayer audioPlayer;

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => true;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  PillcastTreatmentTrackSelectionPage({
    @required this.treatment,
    @required this.audioPlayer,
  });

  @override
  Widget buildTransitions(
          BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(
        child: child,
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _PillcastTreatmentTrackSelection(this.treatment, this.audioPlayer);
}

class _PillcastTreatmentTrackSelection extends StatefulWidget {
  final PillcastAudioTreatment treatment;
  final PillcastAudioPlayer audioPlayer;

  const _PillcastTreatmentTrackSelection(this.treatment, this.audioPlayer);

  @override
  _PillcastTreatmentTrackSelectionState createState() => new _PillcastTreatmentTrackSelectionState();
}

class _PillcastTreatmentTrackSelectionState extends BasePresenter<_PillcastTreatmentTrackSelection> {
  static const double selectedTrackBackgroundOpacity = 0.3;
  static const double unselectedTrackBackgroundOpacity = 0.1;

  PillcastAudioTreatment get treatment => widget.treatment;

  PillcastAudioPlayer get audioPlayer => widget.audioPlayer;

  int get selectedTrackIndex =>
      audioPlayer?.state?.trackPlaying == null ? 0 : treatment.tracks.indexOf(audioPlayer.state.trackPlaying);

  Widget buildHeader() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextScaled(
                    treatment.name.toUpperCase(),
                    style: AppTextStyles.captionZirkonRegular.copyWith(color: AppColors.whiteFaded),
                  ),
                  TextScaled(
                    // TODO: Add time to pillcast tracks JSON if that really what we go for and replace placeholder here.
                    "10m 53s",
                    style: AppTextStyles.captionZirkonRegular.copyWith(color: AppColors.whiteFaded),
                  ),
                ],
              ),
              ColumnSeparator.tinyPlus,
              const SeparatorLine(),
              ColumnSeparator.medium,
            ],
          ),
        ),
      );

  Widget buildTrackListItem(int index) => GestureDetector(
        child: Container(
          height: 56,
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: ColumnSeparator.veryTiny.separatorSize,
          ),
          padding: EdgeInsets.all(smallPadding),
          color: Colors.white.withOpacity(
              selectedTrackIndex == index ? selectedTrackBackgroundOpacity : unselectedTrackBackgroundOpacity),
          child: TextScaled(
            treatment.tracks[index].name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h5ZirkonRegular.copyWith(color: AppColors.whiteFaded),
          ),
        ),
        onTap: () => audioPlayer.playPlayList(treatment.tracks, startingTrackIndex: index),
      );

  Widget buildPlayButton() => GestureDetector(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          width: MediaQuery.of(context).size.width,
          height: PillcastAudioPlayerBar.height + MediaQuery.of(context).padding.bottom,
          alignment: Alignment.center,
          color: Colors.black,
          child: TextScaled(
            localize(context, "pillcast_play_button"),
            style: AppTextStyles.h5ZirkonRegular.copyWith(
              fontSize: 17,
              color: AppColors.pillcastPlayerText,
            ),
          ),
        ),
        onTap: () {
          if (audioPlayer.state.isStopped) {
            audioPlayer.playPlayList(treatment.tracks, startingTrackIndex: 0);
          }
        },
      );

  Widget buildTracksList() => SliverPadding(
        padding: const EdgeInsets.only(bottom: defaultPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => buildTrackListItem(index),
            childCount: treatment.tracks.length,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: <Widget>[
            PillcastPageBackground(),
            StreamBuilder(
              stream: audioPlayer.stream,
              builder: (BuildContext context, _) => Column(
                children: <Widget>[
                  Expanded(
                    child: CustomScrollView(
                      slivers: <Widget>[
                        TreatmentSliverAppBar(treatment),
                        buildHeader(),
                        buildTracksList(),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: !audioPlayer.state.isInitialized,
                    child: buildPlayButton(),
                  ),
                  Visibility(
                    visible: audioPlayer.state.isInitialized,
                    child: PillcastAudioPlayerBar(audioPlayer: audioPlayer),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
