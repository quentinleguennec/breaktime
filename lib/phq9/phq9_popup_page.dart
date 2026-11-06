import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/phq9/phq9_popup_presenter.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/blur_filter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PHQ9PopupPage extends PopupRoute<Null> {
  static const double blurStrength = defaultPadding;
  static const Duration customTransitionDuration = const Duration(milliseconds: 300);

  PHQ9PopupPage() : super(settings: TrackingService.phq9PopupPage);

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => customTransitionDuration;

  @override
  bool get opaque => false;

  @override
  Widget buildTransitions(
          BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      BlurFilter(
        blurStrength: blurStrength,
        animation: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(animation),
        child: Opacity(
          opacity: animation.value,
          child: child,
        ),
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _PageLayout();
}

class _PageLayout extends StatefulWidget {
  _PageLayout();

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements PHQ9PopupPresenterView {
  PHQ9PopupPresenter presenter;

  _PageLayoutState() {
    presenter = PHQ9PopupPresenter(this);
  }

  Widget getTextContainer(BuildContext context) => Container(
        padding: const EdgeInsets.all(defaultPadding),
        width: 280.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
          ),
          color: AppColors.scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextScaled(
              localize(context, "phq9_popup_title").toUpperCase(),
              style: AppTextStyles.bodyReg.copyWith(color: AppColors.warmGrey, letterSpacing: 1.6),
            ),
            ColumnSeparator.medium,
            TextScaled(
              localize(context, "phq9_popup_description_part_1"),
              style: AppTextStyles.bodyReg,
            ),
            ColumnSeparator.medium,
            TextScaled(
              localize(
                  context, App.isDayBreak ? "phq9_daybreak_popup_description_part_2" : "phq9_popup_description_part_2"),
              style: AppTextStyles.bodyReg,
            ),
          ],
        ),
      );

  Widget getButton(BuildContext context) => GestureDetector(
        onTap: presenter.pushPHQ9,
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          width: 280.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(4.0),
              bottomRight: Radius.circular(4.0),
            ),
            color: AppColors.tealish,
          ),
          child: Center(
            child: TextScaled(
              localize(context, App.isDayBreak ? "phq9_daybreak_popup_button" : "phq9_popup_button").toUpperCase(),
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          /// This is to have the blur fill the entire screen and still be able to dismiss the popup by tapping outside of it.
          IgnorePointer(
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getTextContainer(context),
                  getButton(context),
                ],
              ),
            ),
          ),
        ],
      );
}
