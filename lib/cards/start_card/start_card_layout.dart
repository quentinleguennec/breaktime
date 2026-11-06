import 'dart:async';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/start_card/start_card_presenter.dart';
import 'package:aebeze/cards/start_card/start_end_card_shape_image.dart';
import 'package:aebeze/cards/widgets/days_menu.dart';
import 'package:aebeze/dashboard/treatment_animated_image.dart';
import 'package:aebeze/mood_selector/navigation_buttons.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/reveal_container.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:slide_container/slide_container.dart';

import '../../theme.dart';

class StartCardLayout extends BasicCardLayout {
  static const double shapeScaleMultiplier = 1.2;
  static const String _cardContent = "cardContent";
  final bool preventTransitionAnimation;

  StartCardLayout(
    pageContext,
    animator,
    onVideoLoaded,
    onImageLoaded, {
    this.preventTransitionAnimation = false,
  }) : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(_cardContent, BoxConstraints.expand(width: size.width, height: size.height));
    positionChild(_cardContent, Offset.zero);
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addContent(list);
    return list;
  }

  void addContent(LayoutList list) => list.layout(
      _cardContent, () => _CardContent(pageContext, preventTransitionAnimation: preventTransitionAnimation));
}

class _CardContent extends StatefulWidget {
  final PageContext pageContext;
  final bool preventTransitionAnimation;

  _CardContent(
    this.pageContext, {
    this.preventTransitionAnimation = false,
  });

  @override
  _CardContentState createState() => _CardContentState();
}

class _CardContentState extends BasePresenter<_CardContent>
    with TickerProviderStateMixin
    implements StartCardPresenterView {
  static const Duration revealCascadeDelay = const Duration(milliseconds: 125);
  static const int cascadingWidgetsCount = 6;

  final ScrollController scrollController = ScrollController();

  StartCardPresenter presenter;
  AnimatedRevealTransitionController revealTransitionController;
  AnimationController fadeInShapeAnimationController;
  AnimationController fadeOutAllAnimationController;

  Treatment get treatment => widget.pageContext.treatment;

  _CardContentState() {
    presenter = StartCardPresenter(this);
  }

  @override
  void initState() {
    revealTransitionController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: cascadingWidgetsCount,
      baseDuration: const Duration(milliseconds: 300),
      delay: revealCascadeDelay,
    );

    fadeInShapeAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    fadeOutAllAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(refreshState);

    revealTransitionController.forward();

    Future.delayed(revealCascadeDelay * 3.0, () {
      if (mounted) {
        fadeInShapeAnimationController?.forward();
      }
    });

    presenter.updateUserLastOpenedTreatments(treatment);

    super.initState();
  }

  @override
  void dispose() {
    revealTransitionController?.dispose();
    fadeInShapeAnimationController?.dispose();
    fadeOutAllAnimationController?.dispose();
    scrollController?.dispose();
    super.dispose();
  }

  void onDaySelected(Treatment selectedTreatment) async {
    await fadeOutAllAnimationController.forward();
    pushReplacementTreatment(selectedTreatment);
  }

  Widget get daybreakBackground => Image.asset(
        Assets.backgroundDefaultDaybreak,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fill,
      );

  Widget buildShape(BuildContext context) => ParallaxBoxWithTrueParallax(
        scrollController: scrollController,
        parallaxDisplacement: 70,
        child: StartEndCardShapeImage(
          treatment: treatment,
          animation: fadeInShapeAnimationController,
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Opacity(
          opacity: 1 - fadeOutAllAnimationController.value,
          child: Stack(
            children: <Widget>[
              if (App.isDayBreak) daybreakBackground,
              Positioned(
                top: defaultPadding,
                child: buildShape(context),
              ),
              Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: _CascadingWidget(
                              animation: revealTransitionController.nextAnimation,
                              child: NavigationAppBarOverlay(
                                isStatusBarTextWhite: true,
                                onPressed: () => widget.pageContext.slideContainerController
                                    .forceSlide(SlideContainerDirection.topToBottom),
                              ),
                            ),
                          ),
                          Padding(padding: const EdgeInsets.only(top: 150)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: bigPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _CascadingWidget(
                                  animation: revealTransitionController.nextAnimation,
                                  child: _Title(
                                    scale: MediaQuery.of(context).size.width / defaultScreenWidth,
                                    treatment: treatment,
                                  ),
                                ),
                                ColumnSeparator.veryBig,
                                _CascadingWidget(
                                  animation: revealTransitionController.nextAnimation,
                                  child: _IngredientBrief(treatment: treatment),
                                ),
                                ColumnSeparator.veryBig,
                                _CascadingWidget(
                                  animation: revealTransitionController.nextAnimation,
                                  child: _SuitableFor(treatment: treatment),
                                ),
                                ColumnSeparator.veryBig,
                                _CascadingWidget(
                                  animation: revealTransitionController.nextAnimation,
                                  child: _Warning(treatment: treatment),
                                ),
                                ColumnSeparator.huge,
                                _CascadingWidget(
                                  animation: revealTransitionController.nextAnimation,
                                  child: DaysMenu(
                                    currentTreatment: treatment,
                                    allTreatments: presenter.getTreatmentsOfType(treatment.type),
                                    completedTreatments: presenter.completedTreatments,
                                    onDaySelected: onDaySelected,
                                  ),
                                ),
                                ColumnSeparator.big,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RevealContainer(
                    fadeInShapeAnimationController,
                    child: BottomNavigationButton(
                      text: localize(context, "start_card_bottom_button"),
                      onTap: widget.pageContext.onNextPressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _Title extends StatelessWidget {
  final double scale;
  final Treatment treatment;

  _Title({
    @required this.scale,
    @required this.treatment,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextScaled(
            treatment.name ?? "",
            style: AppTextStyles.startCardTitle,
            textScaleFactor: scale,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: TextScaled(
              "${localize(context, "day")} ${treatment.day}".toUpperCase(),
              style: AppTextStyles.bodyLightZirkonBook,
              textScaleFactor: scale,
            ),
          ),
        ],
      );
}

class _IngredientBrief extends StatelessWidget {
  final Treatment treatment;

  _IngredientBrief({@required this.treatment});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextScaled(
            localize(context, "start_card_ingredient_brief").toUpperCase(),
            style: AppTextStyles.startCardIngredientBriefHeader,
          ),
          ColumnSeparator.tinyPlus,
          TextScaled(
            treatment.ingredientsBrief ?? "",
            style: AppTextStyles.h4ZirkonRegular,
          ),
        ],
      );
}

class _SuitableFor extends StatelessWidget {
  final Treatment treatment;

  _SuitableFor({@required this.treatment});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextScaled(
            localize(context, "start_card_suitable_for").toUpperCase(),
            style: AppTextStyles.startCardIngredientBriefHeader,
          ),
          ColumnSeparator.tinyPlus,
          TextScaled(
            treatment.suitableFor ?? "",
            style: AppTextStyles.h4ZirkonRegular,
          ),
        ],
      );
}

class _Warning extends StatelessWidget {
  final Treatment treatment;

  _Warning({@required this.treatment});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextScaled(
            localize(context, "start_card_warning").toUpperCase(),
            style: AppTextStyles.startCardIngredientBriefHeader,
          ),
          ColumnSeparator.tinyPlus,
          TextScaled(
            treatment.warning ?? "",
            style: AppTextStyles.h4ZirkonRegular,
          ),
        ],
      );
}

class _CascadingWidget extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  _CascadingWidget({
    @required this.child,
    @required this.animation,
  });

  @override
  Widget build(BuildContext context) => AnimatedRevealTransitionWidget(
        animation: animation,
        child: child,
        translationValue: 10.0,
      );
}
