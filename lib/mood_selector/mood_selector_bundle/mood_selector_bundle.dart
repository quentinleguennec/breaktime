import 'package:aebeze/app.dart';
import 'package:aebeze/cards/widgets/custom_page_view.dart';
import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle_presenter.dart';
import 'package:aebeze/mood_selector/mood_selector_daybreak/mood_selector_page.dart';
import 'package:aebeze/mood_selector/mood_selector_list/mood_factor_selector_list_page.dart';
import 'package:aebeze/mood_selector/mood_selector_list/mood_selector_list_page.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:slide_container/slide_container.dart';
import 'package:slide_container/slide_container_controller.dart';

class MoodSelectorBundle extends StatefulWidget {
  static final List<Color> backgroundGradientColors = App.isDayBreak
      ? [
          const Color(0xFFCED100),
          const Color(0xFF000000),
        ]
      : [
          const Color(0xFF9FB2EC),
          const Color(0xFF174486),
        ];

  final VoidCallback onComplete;
  final ValueSetter<MoodSelectorBundleData> onUserDataUpdated;
  final SlideContainerController slideContainerController;

  MoodSelectorBundle({
    this.onComplete,
    this.onUserDataUpdated,
    this.slideContainerController,
  });

  @override
  _MoodSelectorBundleState createState() => _MoodSelectorBundleState();
}

class _MoodSelectorBundleState extends BasePresenter<MoodSelectorBundle> implements MoodSelectorBundlePresenterView {
  static const _pageCount = 3;

  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();

  double get backgroundGradientHeight => MediaQuery.of(context).size.height * 2;

  VoidCallback get onComplete => widget.onComplete;

  ValueSetter<MoodSelectorBundleData> get onUserDataUpdated => widget.onUserDataUpdated;

  SlideContainerController get slideContainerController => widget.slideContainerController;

  MoodSelectorBundlePresenter presenter;

  MoodSelectorBundleData userData = MoodSelectorBundleData();

  MoodSelectorBundleController controller = MoodSelectorBundleController();

  int get currentPageIndex {
    if (!pageController.hasClients) {
      return 0;
    }
    try {
      return pageController.page.round();
    } catch (e) {
      // This try/catch shouldn't be needed, it's just a work around for this issue. Remove it when the bug in the framework is fixed.
      // Cf: https://github.com/flutter/flutter/issues/18370
      return 0;
    }
  }

  _MoodSelectorBundleState() {
    presenter = MoodSelectorBundlePresenter(this);
  }

  @override
  void initState() {
    presenter.updateAppStartMoodSelectorLastOpenDate();
    super.initState();
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  void moveToNextPage() {
    if (currentPageIndex == _pageCount - 1) {
      if (onComplete != null) onComplete();
    } else {
      pageController.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.decelerate);
    }
  }

  void moveToPreviousPage() {
    if (currentPageIndex != 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.decelerate);
    }
  }

  void updateBackgroundGradient(double mood) => scrollController.jumpTo((1 - mood) * backgroundGradientHeight * 0.25);

  Widget get backgroundGradient => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        controller: scrollController,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: backgroundGradientHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: MoodSelectorBundle.backgroundGradientColors,
            ),
          ),
        ),
      );

  Widget buildPage(int index) {
    if (index == 0) {
      return MoodSelector(
        onMoodUpdated: (mood) {
          userData = userData.copyWith(moodValue: mood.value);
          onUserDataUpdated?.call(userData);
        },
        onNextButtonPressed: moveToNextPage,
        onCancelButtonPressed: () => slideContainerController.forceSlide(SlideContainerDirection.topToBottom),
        onCircleMoved: updateBackgroundGradient,
      );
    } else if (index == 1) {
      return MoodFeelingsSelectorList(
        slideContainerController: slideContainerController,
        onBackButtonPressed: moveToPreviousPage,
        controller: controller,
        onValuesUpdated: (moodFeelingsSelectedData) {
          userData = userData.copyWith(
            moodFeelings: moodFeelingsSelectedData.selectedFeelings,
            inputFieldsData: moodFeelingsSelectedData.inputFieldsData,
          );
          onUserDataUpdated?.call(userData);
        },
        onNextButtonPressed: moveToNextPage,
      );
    } else {
      return MoodFactorSelectorList(
        slideContainerController: slideContainerController,
        onBackButtonPressed: moveToPreviousPage,
        controller: controller,
        onValuesUpdated: (moodFactorSelectedData) {
          userData = userData.copyWith(
            moodFactors: moodFactorSelectedData.selectedFactors,
            inputFieldsData: moodFactorSelectedData.inputFieldsData,
          );
          onUserDataUpdated?.call(userData);
        },
        onNextButtonPressed: moveToNextPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            backgroundGradient,
            CustomPageView.builder(
              controller: pageController,
              itemCount: _pageCount,
              onPageChanged: (index) => controller.currentPageIndex = index,

              /// Keeping a huge cacheExtent to make sure the pages state is maintained.
              cacheExtent: MediaQuery.of(context).size.width * _pageCount,
              itemBuilder: (BuildContext context, int index) => buildPage(index),
            ),
          ],
        ),
      );
}

@immutable
class MoodSelectorBundleData {
  final int moodValue;
  final List<String> moodFeelings;
  final List<String> moodFactors;
  final Map<String, String> inputFieldsData;

  MoodSelectorBundleData({
    this.moodValue,
    this.moodFeelings,
    this.moodFactors,
    this.inputFieldsData,
  });

  MoodSelectorBundleData copyWith({
    int moodValue,
    List<String> moodFeelings,
    List<String> moodFactors,
    Map<String, String> inputFieldsData,
  }) =>
      MoodSelectorBundleData(
        moodValue: moodValue ?? this.moodValue,
        moodFeelings: moodFeelings ?? this.moodFeelings,
        moodFactors: moodFactors ?? this.moodFactors,
        inputFieldsData: {...?this.inputFieldsData, ...?inputFieldsData},
      );

  bool get isEmpty =>
      moodValue == null && isEmptyOrNull(moodFeelings) && isEmptyOrNull(moodFactors) && isEmptyOrNull(inputFieldsData);

  @override
  String toString() =>
      'MoodSelectorBundleData{moodValue: $moodValue, moodFeelings: $moodFeelings, moodFactors: $moodFactors, inputFieldsData: $inputFieldsData}';
}

class MoodSelectorBundleController extends ChangeNotifier {
  int _currentPageIndex;

  int get currentPageIndex => _currentPageIndex;

  set currentPageIndex(int value) {
    _currentPageIndex = value;
    notifyListeners();
  }
}
