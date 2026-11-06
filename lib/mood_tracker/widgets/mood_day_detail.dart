import 'dart:core';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/mood_selector/mood_button.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/blur_filter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodDayDetail extends StatefulWidget {
  final MoodDayDetailController controller;

  const MoodDayDetail({@required this.controller});

  @override
  _MoodDayDetailState createState() => _MoodDayDetailState();
}

class _MoodDayDetailState extends BasePresenter<MoodDayDetail> with TickerProviderStateMixin {
  static const double backgroundOpacity = 0.6;

  // NOTE: Don't forget to update this if modifying  the number of cascading widgets.
  static const int cascadingWidgetsCount = 3;

  AnimatedRevealTransitionController revealTransitionController;
  AnimationController hideUnhideAnimationController;
  Animation hideUnhideAnimation;

  List<MoodData> get orderedMoodData => controller?.orderedMoodData;

  MoodDayDetailController get controller => widget.controller;

  DateTime get date => orderedMoodData.first.date;

  @override
  void initState() {
    controller?.addListener(onControllerUpdated);

    hideUnhideAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(refreshState);

    hideUnhideAnimation = CurvedAnimation(parent: hideUnhideAnimationController, curve: Curves.easeInCubic);

    revealTransitionController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: 0,
      baseDuration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 100),
    )
      ..animationsCount = cascadingWidgetsCount
      ..addListener(refreshState);

    super.initState();
  }

  @override
  void dispose() {
    hideUnhideAnimationController?.dispose();
    revealTransitionController?.dispose();
    controller?.removeListener(onControllerUpdated);
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?.removeListener(onControllerUpdated);
    widget.controller?.addListener(onControllerUpdated);
  }

  void onControllerUpdated() {
    if (controller.isVisible) {
      revealTransitionController.forward();
      hideUnhideAnimationController.forward();
    } else {
      revealTransitionController.reverse().then((_) => hideUnhideAnimationController.reverse());
    }
  }

  List<Widget> get rows => orderedMoodData.map((moodData) => _MoodRow(moodData)).toList();

  void onCrossPressed() => controller.hide();

  Widget buildCascadingWidget(Widget child, {double opacity = 1}) => AnimatedRevealTransitionWidget(
        animation: revealTransitionController.nextAnimation,
        translationValue: -defaultPadding,
        opacityValue: opacity,
        child: child,
      );

  Widget get dateText => buildCascadingWidget(
        TextScaled(
          DateFormat('MMMM d').format(date),
          style: AppTextStyles.h3SmallProtoGroteskLight.copyWith(color: AppColors.whiteFaded),
        ),
      );

  @override
  Widget build(BuildContext context) => orderedMoodData == null || hideUnhideAnimationController.value == 0
      ? Container()
      : BlurFilter(
          blurStrength: 10.0,
          animation: hideUnhideAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: AppColors.popupBackgroundColor.withOpacity(hideUnhideAnimation.value * backgroundOpacity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: buildCascadingWidget(
                    NavigationAppBarOverlay(
                      withInvertedColor: !App.isDayBreak,
                      onPressed: onCrossPressed,
                    ),
                  ),
                ),
                ColumnSeparator.big,
                ColumnSeparator.tiny,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: dateText,
                ),
                ColumnSeparator.big,
                Expanded(
                  child: buildCascadingWidget(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                          child: const SeparatorLine(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 25, right: defaultPadding),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ColumnSeparator.big,
                                  ...rows,
                                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).padding.bottom)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    opacity: revealTransitionController.currentAnimation.value,
                  ),
                ),
              ],
            ),
          ),
        );
}

class _MoodRow extends StatelessWidget {
  static const double diameter = 48;
  final MoodData moodData;

  _MoodRow(this.moodData);

  Mood get mood => moodData.mood;

  String get moodValue => mood.value > 0 ? "+" + mood.value.toString() : mood.value.toString();

  Widget get coloredCircle => Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: App.isDayBreak ? AppColors.daybreakYellow : AppColors.whiteFaded,
        ),
        child: Center(
          child: TextScaled(
            moodValue,
            style: AppTextStyles.h5ZirkonRegular.copyWith(color: Colors.black.withOpacity(0.95)),
          ),
        ),
      );

  Widget get moodText => TextScaled(
        mood.text,
        style: AppTextStyles.h5ZirkonRegular.copyWith(
          color: App.isDayBreak ? AppColors.daybreakYellow : AppColors.whiteFaded,
          height: 1,
        ),
      );

  Widget get coloredCircleRow => Row(
        children: <Widget>[
          coloredCircle,
          Padding(padding: const EdgeInsets.only(left: defaultPadding)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              time,
              Padding(padding: const EdgeInsets.only(top: 2)),
              moodText,
            ],
          ),
        ],
      );

  Widget get time => TextScaled(
        DateFormat('h.mm a').format(moodData.date),
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyZirkonRegular.copyWith(color: Colors.white.withOpacity(0.6), fontSize: 15.0),
      );

  Widget getCategory(String header, List<String> elements) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextScaled(
            header,
            style: AppTextStyles.bodyZirkonRegular.copyWith(color: Colors.white.withOpacity(0.6), fontSize: 15.0),
          ),
          ColumnSeparator.veryTiny,
          ColumnSeparator.tiny,
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: <Widget>[
              for (int i = 0; i < elements.length; i++) MoodButton(text: elements[i]),
            ],
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(bottom: 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            coloredCircleRow,
            if (moodData.feelings != null && moodData.feelings.isNotEmpty) ...[
              ColumnSeparator.medium,
              getCategory("Emotions", moodData.feelings),
            ],
            if (moodData.factors != null && moodData.factors.isNotEmpty) ...[
              ColumnSeparator.medium,
              getCategory("Factors", moodData.factors),
            ],
          ],
        ),
      );
}

class MoodDayDetailController extends ChangeNotifier {
  List<MoodData> _orderedMoodData;
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  List<MoodData> get orderedMoodData => _orderedMoodData;

  void showDay(List<MoodData> orderedMoodData) {
    _orderedMoodData = orderedMoodData;
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }
}
