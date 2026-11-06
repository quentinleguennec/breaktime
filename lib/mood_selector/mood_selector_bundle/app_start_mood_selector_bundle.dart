import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle.dart';
import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle_presenter.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:slide_container/slide_container.dart';
import 'package:slide_container/slide_container_controller.dart';

class AppStartMoodSelectorBundle extends StatefulWidget {
  @override
  _AppStartMoodSelectorBundleState createState() => _AppStartMoodSelectorBundleState();
}

class _AppStartMoodSelectorBundleState extends BasePresenter<AppStartMoodSelectorBundle>
    with WidgetsBindingObserver
    implements MoodSelectorBundlePresenterView {
  final SlideContainerController slideContainerController = SlideContainerController();

  bool isVisible = true;
  MoodSelectorBundleData userData;

  MoodSelectorBundlePresenter presenter;

  _AppStartMoodSelectorBundleState() {
    presenter = MoodSelectorBundlePresenter(this);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      presenter.checkIfNeedToShowAppStarMoodSelector().then((need) {
        if (need) {
          show();
          presenter.updateAppStartMoodSelectorLastOpenDate();
        }
      });
    }
  }

  void show() => setMountedState(() => isVisible = true);

  void hide() {
    setMountedState(() => isVisible = false);
    slideContainerController.forceSlide(SlideContainerDirection.bottomToTop);
  }

  void onSlideCompleted() {
    hide();
    userData = null;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (isVisible) {
            slideContainerController.forceSlide(SlideContainerDirection.topToBottom);
          }
          return false;
        },
        child: Visibility(
          visible: isVisible,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SlideContainer(
              controller: slideContainerController,
              slideDirection: SlideContainerDirection.topToBottom,
              onSlideCompleted: onSlideCompleted,
              minDragVelocityForAutoSlide: 600.0,
              minSlideDistanceToValidate: MediaQuery.of(context).size.height * 0.5,
              maxSlideDistance: MediaQuery.of(context).size.height,
              autoSlideDuration: const Duration(milliseconds: 300),
              onSlideValidated: () => HapticFeedback.mediumImpact(),
              child: MoodSelectorBundle(
                slideContainerController: slideContainerController,
                onComplete: () {
                  presenter.sendUserData(userData);
                  slideContainerController.forceSlide(SlideContainerDirection.topToBottom);
                },
                onUserDataUpdated: (data) => userData = data,
              ),
            ),
          ),
        ),
      );
}
