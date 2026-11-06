import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle.dart';
import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle_presenter.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/close_treatment_slide_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:slide_container/slide_container.dart';
import 'package:slide_container/slide_container_controller.dart';

class MoodSelectorBundlePage extends PopupRoute<Null> {
  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => false;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  MoodSelectorBundlePage();

  @override
  Widget buildTransitions(
          BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(
        child: child,
        opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _PageLayout();
}

class _PageLayout extends StatefulWidget {
  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements MoodSelectorBundlePresenterView {
  final SlideContainerController slideContainerController = SlideContainerController();

  MoodSelectorBundleData userData;
  MoodSelectorBundlePresenter presenter;

  _PageLayoutState() {
    presenter = MoodSelectorBundlePresenter(this);
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          slideContainerController.forceSlide(SlideContainerDirection.topToBottom);
          return false;
        },
        child: CloseTreatmentSlideContainer(
          controller: slideContainerController,
          child: MoodSelectorBundle(
            slideContainerController: slideContainerController,
            onComplete: () {
              presenter.sendUserData(userData);
              slideContainerController.forceSlide(SlideContainerDirection.topToBottom);
            },
            onUserDataUpdated: (data) => userData = data,
          ),
        ),
      );
}
