import 'dart:async';
import 'dart:convert';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/pillcast/pillcast_audio_player.dart';
import 'package:aebeze/pillcast/pillcast_audio_player_bar.dart';
import 'package:aebeze/pillcast/pillcast_category_tile.dart';
import 'package:aebeze/pillcast/pillcast_treatment_selection_page.dart';
import 'package:aebeze/pillcast/widgets/page_background.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:flutter/material.dart';

class PillcastDashboardPage extends PopupRoute<Null> {
  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => true;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

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
      _PageLayout();
}

class _PageLayout extends StatefulWidget {
  @override
  _PillcastDashboardState createState() => _PillcastDashboardState();
}

class _PillcastDashboardState extends BasePresenter<_PageLayout> with SingleTickerProviderStateMixin {
  static const double sliverAppBarHeight = 240;

  PillcastAudioPlayer audioPlayer;
  List<PillcastAudioTreatment> treatments = List<PillcastAudioTreatment>();
  ScrollController scrollController;
  AnimatedRevealTransitionController revealTransitionController;
  Timer cascadeInTimer;

  int get treatmentsCount => treatments == null || treatments.isEmpty ? 0 : treatments.length;

  @override
  void initState() {
    readTreatmentsFromJson();
    audioPlayer = PillcastAudioPlayer();
    scrollController = ScrollController();

    revealTransitionController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: treatmentsCount,
      baseDuration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 100),
    );

    super.initState();
  }

  @override
  dispose() {
    audioPlayer.dispose();
    scrollController?.dispose();
    revealTransitionController?.dispose();
    cascadeInTimer?.cancel();
    super.dispose();
  }

  void readTreatmentsFromJson() async {
    String json = await DefaultAssetBundle.of(context).loadString(Assets.pillcastAudioTreatmentsJson);
    Map<String, dynamic> jsonData = jsonDecode(json) as Map<String, dynamic>;
    setState(() {
      treatments = PillcastAudioTreatments.fromJson(jsonData).treatments;
    });
    revealTransitionController.animationsCount = treatmentsCount;
    cascadeInTimer = Timer(const Duration(milliseconds: 210), () => revealTransitionController?.forward());
  }

  List<Widget> getCategoryListItems(List<PillcastAudioTreatment> treatments) {
    final List<PillcastAudioTreatment> distincts = List<PillcastAudioTreatment>();
    treatments.forEach((treatment) {
      if (!distincts.any((distinct) => treatment.type == distinct.type)) {
        distincts.add(treatment);
      }
    });

    return distincts
        .map((treatment) => PillcastCategoryListItem(
              treatment: treatment,
              animation: revealTransitionController.nextAnimation,
              onTap: () => onCategorySelected(treatment.type),
              animationTranslationValue: 10,
            ))
        .toList();
  }

  void onCategorySelected(String categoryType) => push(
        PillcastTreatmentSelectionPage(
          treatments: treatments.where((treatment) => treatment.type == categoryType).toList(),
          audioPlayer: audioPlayer,
        ),
      );

  Widget buildDescription() => Text(
        localize(context, "pillcast_dashboard_description"),
        style: AppTextStyles.subCategory,
      );

  Widget buildSliverAppBar() => SliverAppBar(
        automaticallyImplyLeading: false,
        floating: false,
        pinned: false,
        snap: false,
        expandedHeight: sliverAppBarHeight - MediaQuery.of(context).padding.top,
        backgroundColor: Colors.transparent,

        /// This allows to set the minimum height of the bar.
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Container(),
        ),
        flexibleSpace: Container(
          height: sliverAppBarHeight,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NavigationAppBarOverlay(
                withInvertedColor: !App.isDayBreak,
              ),
              Expanded(flex: 6, child: Container()),
              PageTitle(text: localize(context, "pillcast_dashboard_title")),
              Expanded(flex: 2, child: Container()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: buildDescription(),
              ),
              Expanded(flex: 5, child: Container()),
            ],
          ),
        ),
      );

  Widget buildCategoriesList() => SliverPadding(
        padding: EdgeInsets.only(
          left: smallPadding,
          right: smallPadding,
          top: smallPadding,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            getCategoryListItems(treatments),
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
                    child: Container(
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: <Widget>[
                          buildSliverAppBar(),
                          buildCategoriesList(),
                        ],
                      ),
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
