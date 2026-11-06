import 'dart:async';

import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/authentication/authentication_page.dart';
import 'package:aebeze/authentication/email_verification_page.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/mood_selector/mood_selector_bundle/mood_selector_bundle_page.dart';
import 'package:aebeze/mood_tracker/insights_page.dart';
import 'package:aebeze/phq9/phq9_popup_page.dart';
import 'package:aebeze/pillcast/pillcast_dashboard_page.dart';
import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/user_account/user_account_page.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WorkInProgressException implements Exception {}

mixin ProgressMixin<T extends StatefulWidget> on State<T> implements _ProgressPresenterView {
  bool inProgress;

  @override
  void initState() {
    inProgress = false;
    super.initState();
  }

  @override
  void startProgress() {
    if (mounted) setState(() => inProgress = true);
  }

  @override
  void stopProgress() {
    if (mounted) setState(() => inProgress = false);
  }
}

mixin _RouteMixin<T extends StatefulWidget> on State<T> implements _RoutePresenterView {
  @override
  void initState() {
    super.initState();
  }

  @override
  Future<Null> replaceWith(Route route) => Navigator.of(context).pushReplacement(route);

  @override
  Future<Null> replaceWithNamed(String route) => Navigator.of(context).pushReplacementNamed(route);

  @override
  Future<dynamic> push(Route route) => Navigator.of(context).push(route);

  @override
  void pushNamed(String route) => Navigator.of(context).pushNamed(route);

  @override
  void pop({dynamic result}) => Navigator.pop(context, result);

  @override
  Future<Null> pushReplacementTreatment(
    Treatment treatment, {
    bool preventStartCardTransitionAnimation = false,
    VoidCallback onTreatmentCompleted,
    VoidCallback onNextPressed,
  }) =>
      replaceWith(
        CardsPage(
          treatment: treatment,
          preventStartCardTransitionAnimation: preventStartCardTransitionAnimation,
          onTreatmentCompleted: onTreatmentCompleted,
          onNextPressed: onNextPressed,
        ),
      );

  Future<Null> pushAuthenticationPage() => push(AuthenticationPage());

  Future<Null> pushPHQ9PopupPage() => push(PHQ9PopupPage());

  Future<Null> pushEmailVerificationPage() => push(EmailVerificationPage());

  @override
  Future<Null> pushTreatment(
    Treatment treatment, {
    bool preventStartCardTransitionAnimation = false,
    bool isRecommendedTreatment = false,
    VoidCallback onTreatmentCompleted,
  }) =>
      push(
        CardsPage(
          treatment: treatment,
          preventStartCardTransitionAnimation: preventStartCardTransitionAnimation,
          isRecommendedTreatment: isRecommendedTreatment,
          onTreatmentCompleted: onTreatmentCompleted,
        ),
      );

  @override
  Future<Mood> pushMoodSelector({Mood mood, bool waitSaveCompletition}) => push(MoodSelectorBundlePage());

  @override
  Future<Null> pushSavedCard(DataCard card) => pushTreatment(Treatment.fromSavedCard(card));

  @override
  Future<Null> pushDeepLinkCard(DataCard card) => pushTreatment(Treatment.fromDeepLinkCard(card));

  @override
  Future<Null> pushMoodTracker() => push(InsightsPage());

  @override
  Future<Null> pushPillcast() => push(PillcastDashboardPage());

  Future<Null> pushUserAccountPage() => push(UserAccountPage());
}

abstract class BasePresenter<T extends StatefulWidget> extends SafeState<T>
    with ProgressMixin<T>, _RouteMixin<T>
    implements BasePresenterView {
  @override
  void showNotImplemented({ScaffoldState scaffoldState}) =>
      showSnackBarMessage("Not implemented", scaffoldState: scaffoldState);

  @override
  void showError(dynamic e, {ScaffoldState scaffoldState}) {
    if (e is ApiException) {
      showSnackBarException(e, scaffoldState: scaffoldState);
      return;
    }

    if (e is Error) {
      print("ERROR: Unhandled error: ${e.stackTrace}");
    } else if (e is Exception) {
      print("ERROR: Unhandled error: $e");
    }

    showSnackBarMessage(localize(context, "unknown_error"), scaffoldState: scaffoldState);
  }

  @override
  void showSnackBarException(Exception e, {ScaffoldState scaffoldState}) {
    print("showSnackBar with exception: $e");
    String msg;
    if (e != null) {
      if (e is WorkInProgressException) {
        msg = localize(context, "error_work_in_progress");
      } else if (e is ApiException) {
        msg = e.getLocalizedMessage(context);
      } else {
        msg = e.toString();
      }
    }
    showSnackBarMessage(msg ?? localize(context, "unknown_error"), scaffoldState: scaffoldState);
  }

  @override
  void showSnackBarMessage(String message, {ScaffoldState scaffoldState}) =>
      runZoned(() => _showSnackBar(message, scaffoldState: scaffoldState), onError: (e, s) {
        print("Couldn't show snackbar: $e");
      });

  Future<dynamic> _showSnackBar(String message, {@required ScaffoldState scaffoldState}) {
    assert(
        scaffoldState != null || context != null,
        "Cannot show Snackbar, context is invalid.  Pass a ScaffoldState to the function.\n"
        "You can obtain one with a Builder as described here:\n"
        "https://docs.flutter.io/flutter/material/Scaffold/of.html");

    return Future.delayed(Duration(milliseconds: 50), () {
      SnackBar snackBar = SnackBar(
        content: TextScaled(message),
        duration: Duration(seconds: 3),
      );
      if (scaffoldState != null) {
        scaffoldState.showSnackBar(snackBar);
      } else if (getScaffoldKey() != null) {
        getScaffoldKey().currentState.showSnackBar(snackBar);
      } else if (context != null) {
        // This will likely fail because we need the context of the child of a Scaffold and [context] here is usually the context of a Scaffold itself.
        Scaffold.of(context).showSnackBar(snackBar);
      }
    });
  }

  Future<Null> showNetworkAlertDialog() => showAlertDialog(
        "alert_generic_netword_error_title",
        "alert_generic_netword_error_msg",
        "alert_generic_netword_error_action",
      );

  Future<Null> showAlertDialog(
    String title,
    String description,
    String action, {
    VoidCallback onActionButtonPressed,
  }) =>
      Theme.of(context).platform == TargetPlatform.iOS
          ? showAlertDialogIOS(title, description, action, onActionButtonPressed: onActionButtonPressed)
          : showAlertDialogAndroid(title, description, action, onActionButtonPressed: onActionButtonPressed);

  Future<Null> showAlertDialogAndroid(String title, String description, String action,
      {VoidCallback onActionButtonPressed}) {
    Widget alertTitle;
    if (title != null) {
      alertTitle = TextScaled(localize(context, title), style: AppTextStyles.h4);
    }

    Widget alertContent = SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          TextScaled(localize(context, description), style: AppTextStyles.bodyReg),
        ],
      ),
    );

    List<Widget> alertActions = <Widget>[
      FlatButton(
        child: TextScaled(
          localize(context, action).toUpperCase(),
          style: AppTextStyles.button,
        ),
        onPressed: () {
          onActionButtonPressed?.call();
          Navigator.of(context).pop();
        },
      ),
    ];

    Widget alertWidget = AlertDialog(
      title: alertTitle,
      content: alertContent,
      actions: alertActions,
      backgroundColor: AppColors.scaffoldBackgroundColor,
    );

    return showDialog<Null>(context: context, barrierDismissible: false, builder: (context) => alertWidget);
  }

  Future<Null> showAlertDialogIOS(String title, String description, String action,
      {VoidCallback onActionButtonPressed}) {
    Widget alertTitle;
    if (title != null) {
      alertTitle = TextScaled(
        localize(context, title),
        style: AppTextStyles.h4.copyWith(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      );
    }

    Widget alertContent = SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          TextScaled(
            localize(context, description),
            style: AppTextStyles.bodyReg.copyWith(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );

    List<Widget> alertActions = <Widget>[
      CupertinoDialogAction(
        isDefaultAction: true,
        child: TextScaled(
          localize(context, action).toUpperCase(),
          style: AppTextStyles.button,
        ),
        onPressed: () {
          onActionButtonPressed?.call();
          Navigator.of(context).pop();
        },
      ),
    ];

    Widget alertWidget = CupertinoAlertDialog(
      title: alertTitle,
      content: alertContent,
      actions: alertActions,
    );

    return showDialog<Null>(context: context, barrierDismissible: false, builder: (context) => alertWidget);
  }

  GlobalKey<ScaffoldState> getScaffoldKey() => null;
}

abstract class _ErrorPresenterView {
  void showError(dynamic e);

  void showSnackBarException(Exception e);

  void showSnackBarMessage(String message, {ScaffoldState scaffoldState});

  void showNotImplemented();

  Future<Null> showNetworkAlertDialog();

  Future<Null> showAlertDialog(String title, String description, String action, {VoidCallback onActionButtonPressed});
}

abstract class _ProgressPresenterView {
  void startProgress();

  void stopProgress();
}

abstract class _RoutePresenterView {
  Future<Null> replaceWith(Route route);

  Future<Null> replaceWithNamed(String route);

  Future<dynamic> push(Route route);

  void pushNamed(String route);

  void pop({dynamic result});

  Future<Null> pushAuthenticationPage();

  Future<Null> pushPHQ9PopupPage();

  Future<Null> pushEmailVerificationPage();

  Future<Null> pushReplacementTreatment(
    Treatment treatment, {
    bool preventStartCardTransitionAnimation = false,
  });

  Future<Null> pushTreatment(
    Treatment treatment, {
    bool preventStartCardTransitionAnimation = false,
    bool isRecommendedTreatment = false,
    VoidCallback onTreatmentCompleted,
  });

  Future<Mood> pushMoodSelector({Mood mood});

  Future<Null> pushSavedCard(DataCard card);

  Future<Null> pushDeepLinkCard(DataCard card);

  Future<Null> pushMoodTracker();

  Future<Null> pushPillcast();

  Future<Null> pushUserAccountPage();
}

abstract class BasePresenterView implements _ErrorPresenterView, _ProgressPresenterView, _RoutePresenterView {}
