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

import 'mood_factor_selector_list_presenter.dart';

class MoodFactorSelectorList extends StatefulWidget {
  final ValueSetter<MoodFactorsSelectedData> onValuesUpdated;
  final VoidCallback onNextButtonPressed;
  final SlideContainerController slideContainerController;
  final VoidCallback onBackButtonPressed;
  final MoodSelectorBundleController controller;
  static final List<FactorsCategory> factorsCategories = [
    FactorsCategory(
      "physical_symptoms",
      "Physical Symptoms",
      [
        "Chronic pain",
        "Headache",
        "Cold/Flu",
        "Low energy",
        "Disturbed sleep",
        "Menopause",
        "Menstruation",
        'Low sex drive',
        "Loss of pleasure",
        "Loss of motivation",
        "Lack of focus",
        "Inflammation",
        "Diarrhea",
        "Constipation",
        "Loss of appetite",
        "Increased appetite",
        "Stomachache",
        "COVID-19"
      ],
    ),
    FactorsCategory(
      "schedule",
      "Schedule",
      [
        "Home",
        "Work",
        "School",
        "Socializing",
        "Shopping",
        "Outdoors",
        "Travel",
        "Down time",
        "Isolation",
        "Day shift",
        "Night shift",
        "Over time",
        "Weekend work",
        "Work from home",
        "Quarantine"
      ],
    ),
    FactorsCategory(
      "relationship",
      "Relationship",
      ["Being by myself", "Partner", "Family", "Date", "Friends", "Colleagues", "Social Distancing"],
    ),
    FactorsCategory(
      "eating",
      "Eating",
      [
        "Great meal",
        "Junk food",
        "Veggie/vegan",
        "Meat",
        "Over eating",
        "Under eating",
        "Dieting",
        "Bad relationship with food"
      ],
    ),
    FactorsCategory(
      "tech",
      "Technology",
      ["Gaming", "Youtube", "Netflix", "Instagram", "Facebook", "Twitter", "Other social media", "TV", "News"],
    ),
    FactorsCategory(
      "hobbies_activities",
      "Hobbies/Activities",
      ["Reading", "Writing", "Lockdown", "Making/listening to music"],
    ),
  ];

  MoodFactorSelectorList({
    this.onBackButtonPressed,
    this.onValuesUpdated,
    this.onNextButtonPressed,
    this.slideContainerController,
    this.controller,
  });

  @override
  _MoodFactorSelectorListState createState() => _MoodFactorSelectorListState();
}

class _MoodFactorSelectorListState extends BasePresenter<MoodFactorSelectorList>
    with TickerProviderStateMixin
    implements MoodFactorSelectorListPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MoodFactorSelectorListPresenter presenter;
  List<int> selectedFactorsIndexes = List<int>();
  List<AnimationController> buttonsActiveStateAnimationControllers = List<AnimationController>();
  List<String> factors = List<String>();
  Map<String, String> inputFieldsData = {};
  SlideContainerController slideContainerController;
  AnimatedRevealTransitionController revealTransitionController;

  List<String> get selectedFactors => selectedFactorsIndexes?.map((index) => factors[index])?.toList();

  MoodSelectorBundleController get controller => widget.controller;

  _MoodFactorSelectorListState() {
    presenter = MoodFactorSelectorListPresenter(this);
  }

  @override
  void initState() {
    slideContainerController = widget.slideContainerController ?? SlideContainerController();

    MoodFactorSelectorList.factorsCategories.forEach(
      (category) => category.factors.forEach((factor) {
        buttonsActiveStateAnimationControllers
            .add(AnimationController(vsync: this, duration: const Duration(milliseconds: 200)));
        factors.add(factor);
      }),
    );

    revealTransitionController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: buttonsActiveStateAnimationControllers.length + MoodFactorSelectorList.factorsCategories.length,
      baseDuration: MoodButton.cascadeDuration,
      delay: MoodButton.cascadeDelay,
    );

    controller?.addListener(onPageChanged);

    super.initState();
  }

  @override
  void dispose() {
    revealTransitionController?.dispose();
    buttonsActiveStateAnimationControllers.forEach((controller) => controller?.dispose());
    super.dispose();
  }

  @override
  void didUpdateWidget(MoodFactorSelectorList oldWidget) {
    oldWidget.controller?.removeListener(onPageChanged);
    controller?.addListener(onPageChanged);
    super.didUpdateWidget(oldWidget);
  }

  void onPageChanged() {
    if (controller.currentPageIndex == 2) {
      revealTransitionController.forward();
    } else if (revealTransitionController.isAnimating) {
      revealTransitionController.stop();
      revealTransitionController.value = 1;
    }
  }

  void onCaptureButtonPressed() => widget.onNextButtonPressed?.call();

  void onBackButtonPressed() => widget.onBackButtonPressed?.call();

  Widget getFactorButton(int factorIndex) => GestureDetector(
        onTap: () {
          if (selectedFactorsIndexes.contains(factorIndex)) {
            buttonsActiveStateAnimationControllers[factorIndex].reverse();
            selectedFactorsIndexes.remove(factorIndex);
          } else {
            selectedFactorsIndexes.add(factorIndex);
            buttonsActiveStateAnimationControllers[factorIndex].forward();
          }
          widget.onValuesUpdated?.call(MoodFactorsSelectedData(selectedFactors, inputFieldsData));
        },
        child: MoodButton(
          text: factors[factorIndex],
          activeStateAnimation: buttonsActiveStateAnimationControllers[factorIndex],
          cascadingRevealAnimation: revealTransitionController.nextAnimation,
        ),
      );

  Widget getInputField(String fieldUID) => MoodSelectorInputField(
        cascadingRevealAnimation: revealTransitionController.nextAnimation,
        style: AppTextStyles.inputField.copyWith(color: Colors.white),
        onChange: (text) {
          inputFieldsData[fieldUID] = text;
          widget.onValuesUpdated?.call(MoodFactorsSelectedData(selectedFactors, inputFieldsData));
        },
      );

  Widget getCategoryTitle(String title) => TextScaled(
        title.toUpperCase(),
        style: AppTextStyles.moodSelectorCategoryTitle,
      );

  Widget getCategoryButtonsAndHeader(FactorsCategory category) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getCategoryTitle(category.title),
          ColumnSeparator.big,
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 15.0,
            children: <Widget>[
              for (int i = 0; i < category.factors.length; i++) getFactorButton(factors.indexOf(category.factors[i])),
              getInputField(category.uid),
            ],
          ),
          ColumnSeparator.veryBig,
        ],
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
                    localize(context, "mood_selector_factor_list_factors_are"),
                    style: AppTextStyles.h3SmallProtoGroteskLight.copyWith(color: Colors.white),
                  ),
                  ColumnSeparator.veryBig,
                  for (int i = 0; i < MoodFactorSelectorList.factorsCategories.length; i++)
                    getCategoryButtonsAndHeader(MoodFactorSelectorList.factorsCategories[i]),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
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
                text: localize(context, "button_done"),
                onTap: onCaptureButtonPressed,
              ),
            ),
          ],
        ),
      );
}

@immutable
class FactorsCategory {
  final List<String> factors;
  final String title;
  final String uid;

  FactorsCategory(this.uid, this.title, this.factors);
}

@immutable
class MoodFactorsSelectedData {
  final List<String> selectedFactors;
  final Map<String, String> inputFieldsData;

  MoodFactorsSelectedData(this.selectedFactors, this.inputFieldsData);
}
