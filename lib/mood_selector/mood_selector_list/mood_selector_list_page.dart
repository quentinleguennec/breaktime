import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/mood_selector/mood_button.dart';
import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle.dart';
import 'package:aebeze/mood_selector/mood_selector_input_field.dart';
import 'package:aebeze/mood_selector/navigation_buttons.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:slide_container/slide_container_controller.dart';
import 'package:slide_container/widgets/slide_container_scroll_view.dart';

import 'mood_selector_list_presenter.dart';

class MoodFeelingsSelectorList extends StatefulWidget {
  final VoidCallback onBackButtonPressed;
  final ValueSetter<MoodFeelingsSelectedData> onValuesUpdated;
  final VoidCallback onNextButtonPressed;
  final SlideContainerController slideContainerController;
  final MoodSelectorBundleController controller;
  static const List<String> feelings = [...positiveMoodTexts, ...negativeMoodTexts];
  static const List<String> positiveMoodTexts = [
    "Excited",
    "Happy",
    "Confident",
    "Optimistic",
    "Proud",
    "Joyful",
    "Grateful",
    "Calm",
    "Okay",
    "Interested",
    "Relaxed",
    "Relieved",
    "Energized",
    "Invigorated",
    "Ecstatic",
    "Amazed",
    "Focused",
    "Anticipation",
    "Vigilant",
    "Connected",
    "Proud",
    "Admiration",
    "Strong",
    "Willful",
    "Willing",
    "Surprised",
    "Curious",
    "Amazed",
  ];
  static const List<String> negativeMoodTexts = [
    "Bored",
    "Tired",
    "Frustrated",
    "Disgusted",
    "Stressed",
    "Angry",
    "Insecure",
    "Anxious",
    "Afraid",
    "Ashamed",
    "Lonely",
    "Sad",
    "Upset",
    "Grief",
    "Rageful",
    "Annoyed",
    "Loathing",
    "Apprehensive",
    "Envious",
    "Depressed",
    "Depleted",
    "Weak",
  ];

  MoodFeelingsSelectorList({
    this.onBackButtonPressed,
    this.onValuesUpdated,
    this.onNextButtonPressed,
    this.slideContainerController,
    this.controller,
  });

  @override
  _MoodFeelingsSelectorListState createState() => _MoodFeelingsSelectorListState();
}

class _MoodFeelingsSelectorListState extends BasePresenter<MoodFeelingsSelectorList>
    with TickerProviderStateMixin
    implements MoodSelectorListPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MoodFeelingsSelectorListPresenter presenter;
  List<AnimationController> moodButtonsAnimationControllers;
  List<int> selectedFeelingsIndexes = List<int>();
  Map<String, String> inputFieldsData = {};
  SlideContainerController slideContainerController;
  AnimatedRevealTransitionController revealTransitionController;

  MoodSelectorBundleController get controller => widget.controller;

  List<String> get selectedFeelings =>
      selectedFeelingsIndexes?.map((index) => MoodFeelingsSelectorList.feelings[index])?.toList();

  _MoodFeelingsSelectorListState() {
    presenter = MoodFeelingsSelectorListPresenter(this);
  }

  @override
  void initState() {
    slideContainerController = widget.slideContainerController ?? SlideContainerController();

    moodButtonsAnimationControllers = List.generate(
      MoodFeelingsSelectorList.feelings.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 200)),
    );

    revealTransitionController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: moodButtonsAnimationControllers.length + 2,
      baseDuration: MoodButton.cascadeDuration,
      delay: MoodButton.cascadeDelay,
    );

    controller?.addListener(onPageChanged);

    super.initState();
  }

  @override
  void dispose() {
    revealTransitionController?.dispose();
    moodButtonsAnimationControllers?.forEach((controller) => controller?.dispose());
    controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MoodFeelingsSelectorList oldWidget) {
    oldWidget.controller?.removeListener(onPageChanged);
    controller?.addListener(onPageChanged);
    super.didUpdateWidget(oldWidget);
  }

  void onCaptureButtonPressed() => widget.onNextButtonPressed?.call();

  void onBackButtonPressed() => widget.onBackButtonPressed?.call();

  void onPageChanged() {
    if (controller.currentPageIndex == 1) {
      revealTransitionController.forward();
    } else if (revealTransitionController.isAnimating) {
      revealTransitionController.stop();
      revealTransitionController.value = 1;
    }
  }

  Widget getMoodButton(int moodIndex) => GestureDetector(
        onTap: () {
          if (selectedFeelingsIndexes.contains(moodIndex)) {
            selectedFeelingsIndexes.remove(moodIndex);
            moodButtonsAnimationControllers[moodIndex].reverse();
          } else {
            selectedFeelingsIndexes.add(moodIndex);
            moodButtonsAnimationControllers[moodIndex].forward();
          }
          widget.onValuesUpdated?.call(MoodFeelingsSelectedData(selectedFeelings, inputFieldsData));
        },
        child: MoodButton(
          text: MoodFeelingsSelectorList.feelings[moodIndex],
          activeStateAnimation: moodButtonsAnimationControllers[moodIndex],
          cascadingRevealAnimation: revealTransitionController.nextAnimation,
        ),
      );

  Widget getInputField(String fieldUID) => MoodSelectorInputField(
        cascadingRevealAnimation: revealTransitionController.nextAnimation,
        style: AppTextStyles.inputField.copyWith(color: Colors.white),
        onChange: (text) {
          inputFieldsData[fieldUID] = text;
          widget.onValuesUpdated?.call(MoodFeelingsSelectedData(selectedFeelings, inputFieldsData));
        },
      );

  Widget get scrollViewContent => Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NavigationAppBarOverlay(
              isCancel: false,
              onPressed: onBackButtonPressed,
              withInvertedColor: !App.isDayBreak,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ColumnSeparator.veryBig,
                  TextScaled(
                    localize(context, "mood_selector_list_im_feeling"),
                    style: AppTextStyles.h3SmallProtoGroteskLight.copyWith(color: Colors.white),
                  ),
                  ColumnSeparator.veryBig,
                  TextScaled(
                    localize(context, "mood_selector_list_positive").toUpperCase(),
                    style: AppTextStyles.moodSelectorCategoryTitle,
                  ),
                  ColumnSeparator.big,
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: defaultPadding,
                    children: <Widget>[
                      for (int i = 0; i < MoodFeelingsSelectorList.positiveMoodTexts.length; i++) getMoodButton(i),
                      getInputField('positive'),
                    ],
                  ),
                  ColumnSeparator.veryBig,
                  TextScaled(localize(context, "mood_selector_list_negative").toUpperCase(),
                      style: AppTextStyles.moodSelectorCategoryTitle),
                  ColumnSeparator.big,
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: defaultPadding,
                    children: <Widget>[
                      for (int i = MoodFeelingsSelectorList.positiveMoodTexts.length;
                          i < MoodFeelingsSelectorList.feelings.length;
                          i++)
                        getMoodButton(i),
                      getInputField('negative'),
                    ],
                  ),
                  ColumnSeparator.veryBig,
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            Expanded(
              child: SlideContainerScrollView(
                slideContainerController: slideContainerController,
                child: scrollViewContent,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavigationButton(
                text: localize(context, "button_next"),
                onTap: onCaptureButtonPressed,
              ),
            ),
          ],
        ),
      );
}

@immutable
class MoodFeelingsSelectedData {
  final List<String> selectedFeelings;
  final Map<String, String> inputFieldsData;

  MoodFeelingsSelectedData(this.selectedFeelings, this.inputFieldsData);
}
