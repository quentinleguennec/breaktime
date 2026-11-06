import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/pillcast/pillcast_audio_player.dart';
import 'package:aebeze/pillcast/pillcast_audio_player_bar.dart';
import 'package:aebeze/pillcast/pillcast_treatment_track_selection_page.dart';
import 'package:aebeze/pillcast/widgets/page_background.dart';
import 'package:aebeze/pillcast/widgets/treatment_sliver_app_bar.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class PillcastTreatmentSelectionPage extends PopupRoute<Null> {
  final List<PillcastAudioTreatment> treatments;
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

  PillcastTreatmentSelectionPage({
    @required this.treatments,
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
      _PillcastTreatmentSelection(this.treatments, this.audioPlayer);
}

class _PillcastTreatmentSelection extends StatefulWidget {
  final List<PillcastAudioTreatment> treatments;
  final PillcastAudioPlayer audioPlayer;

  const _PillcastTreatmentSelection(this.treatments, this.audioPlayer);

  @override
  _PillcastTreatmentSelectionState createState() => new _PillcastTreatmentSelectionState();
}

class _PillcastTreatmentSelectionState extends BasePresenter<_PillcastTreatmentSelection> {
  PillcastAudioPlayer get audioPlayer => widget.audioPlayer;

  List<PillcastAudioTreatment> get treatments => widget.treatments;

  bool didUserCompleteTreatment(PillcastAudioTreatment treatment) {
    Set<String> userCompletedTracksUids = Injector().cache.userPillcastCompletedTracksUids;
    return treatment.tracks.every((track) => userCompletedTracksUids.contains(track.uid));
  }

  Widget buildTreatmentsList() => SliverPadding(
        padding: EdgeInsets.only(top: 25, bottom: MediaQuery.of(context).padding.bottom),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _TreatmentListItem(
              treatment: treatments[index],
              isCompleted: didUserCompleteTreatment(treatments[index]),
              onTap: () => push(
                PillcastTreatmentTrackSelectionPage(
                  treatment: treatments[index],
                  audioPlayer: audioPlayer,
                ),
              ),
            ),
            childCount: treatments?.length ?? 0,
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
                        TreatmentSliverAppBar(treatments.first),
                        buildTreatmentsList(),
                      ],
                    ),
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

class _TreatmentListItem extends StatelessWidget {
  final PillcastAudioTreatment treatment;
  final bool isCompleted;
  final VoidCallback onTap;

  const _TreatmentListItem({
    @required this.treatment,
    @required this.isCompleted,
    @required this.onTap,
  });

  Widget buildPlayIconBox() => Container(
        alignment: Alignment.center,
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.transparentBoxBackgroundColor : AppColors.whiteFaded,
          shape: BoxShape.circle,
        ),
        child: Image(
          width: 20,
          height: 20,
          color: isCompleted ? Colors.white : Colors.black,
          image: AssetImage(
            isCompleted ? Assets.pillcastCheckMark : Assets.pillcastPlayButton,
          ),
        ),
      );

  Widget buildTitleAndText(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextScaled(
                  treatment.name.toUpperCase(),
                  style: AppTextStyles.captionZirkonRegular.copyWith(
                    color: isCompleted ? Colors.white.withOpacity(0.6) : AppColors.whiteFaded,
                  ),
                ),
                TextScaled(
                  // TODO: Add time to pillcast tracks JSON if that really what we go for and replace placeholder here.
                  "10m 53s",
                  style: AppTextStyles.captionZirkonRegular.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            ColumnSeparator.tinyPlus,
            TextScaled(
              treatment.getDescriptionText(context),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.smallText,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: GestureDetector(
          child: Container(
            padding: EdgeInsets.only(bottom: 18),
            child: Row(
              children: <Widget>[
                buildPlayIconBox(),
                Expanded(child: buildTitleAndText(context)),
              ],
            ),
          ),
          onTap: onTap,
        ),
      );
}
