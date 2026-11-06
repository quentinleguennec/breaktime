import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/user_account/saved_cards/saved_cards.dart';
import 'package:aebeze/user_account/user_account_presenter.dart';
import 'package:aebeze/user_account/widgets/account_row.dart';
import 'package:aebeze/user_account/widgets/page_background.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/sub_category_header.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:launch_review/launch_review.dart';

class UserAccountPage extends PopupRoute<Null> {
  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => true;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  UserAccountPage() : super(settings: TrackingService.accountPage);

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
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements UserAccountPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserAccountPresenter presenter;
  User user;
  Mood mood;

  bool get isUserLoggedIn => user?.isAnonymous == false;

  bool get isUserVerified => user?.isVerified == true;

  @override
  void initState() {
    presenter = UserAccountPresenter(this);
    presenter.loadUser();
    super.initState();
  }

  void openMoodSelector() async {
    Injector().trackingService.trackMood(source: "profile_track_mood_button");
    await pushMoodSelector(mood: mood, waitSaveCompletition: true);
    refreshState();
  }

  @override
  void updateUser(User user) => setMountedState(() => this.user = user);

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  Widget get userEmailText => TextScaled(
        user?.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.subCategory,
      );

  Widget get settingsSubCategoryHeader => Column(
        children: [
          TextScaled(
            localize(context, "dashboard_your_saved_cards"),
            style: AppTextStyles.subCategory,
          ),
          ColumnSeparator.tiny,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: const SeparatorLine(),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            UserAccountPageBackground(),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: NavigationAppBarOverlay(
                      withInvertedColor: !App.isDayBreak,
                    ),
                  ),
                  ColumnSeparator.veryBig,
                  PageTitle(text: localize(context, "dashboard_icon_user_account")),
                  if (isUserLoggedIn) ...[
                    ColumnSeparator.tiny,
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: userEmailText,
                    ),
                    ColumnSeparator.big,
                    SavedCards(onCardSelected: (card) => pushSavedCard(card)),
                  ],
                  ColumnSeparator.veryBig,
                  SubCategoryHeader(
                    title: localize(context, "user_account_settings"),
                    padding: defaultPadding,
                  ),
                  ColumnSeparator.medium,
                  if (isUserLoggedIn && !isUserVerified)
                    AccountRow(
                      title: localize(context, "please_verify"),
                      onTap: presenter.showEmailVerificationPage,
                    ),
                  AccountRow(
                    title: localize(context, "manage_notifications"),
                    onTap: presenter.showManageNotificationsPage,
                  ),
                  isUserLoggedIn
                      ? AccountRow(
                          height: 54,
                          title: localize(context, "log_out"),
                          onTap: presenter.logOut,
                        )
                      : AccountRow(
                          title: localize(context, "login"),
                          onTap: presenter.showLoginPage,
                        ),
                  if (App.inDebugMode)
                    AccountRow(
                      title: localize(context, "ask_for_review"),
                      onTap: () => LaunchReview.launch(
                        androidAppId: aebezeAndroidAppId,
                        iOSAppId: aebezeIosAppId,
                      ),
                    ),
                  AccountRow(
                    title: localize(context, "about_button"),
                    onTap: presenter.showAboutPage,
                  ),
                  AccountRow(
                    title: localize(context, "privacy_policy"),
                    onTap: presenter.showTermsPage,
                  ),
                  if (App.isDayBreak)
                    AccountRow(
                      title: localize(context, "emergency_contacts"),
                      onTap: presenter.showEmergencyContactsPage,
                    ),
                  if (App.inDebugMode) AccountRow(title: "Endpoint: ${App.projectId}"),
                  ColumnSeparator.huge,
                ],
              ),
            ),
          ],
        ),
      );
}
