import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/authentication/authentication_presenter.dart';
import 'package:aebeze/authentication/email_verification_page.dart';
import 'package:aebeze/authentication/log_in_page.dart';
import 'package:aebeze/authentication/sign_up_page.dart';
import 'package:aebeze/authentication/widgets/page_background.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class AuthenticationPage extends MaterialPageRoute<Null> {
  AuthenticationPage()
      : super(
          builder: (context) => AuthenticationWidget(
            pageType: AuthenticationPageType.authentication,
            onComplete: () => Navigator.of(context).pop(),
          ),
          settings: TrackingService.authenticationPage,
        );
}

class AuthenticationWidget extends StatefulWidget {
  final bool isForcedAuthentication;
  final VoidCallback onComplete;
  final AuthenticationPageType pageType;

  AuthenticationWidget({
    this.isForcedAuthentication = false,
    this.pageType = AuthenticationPageType.authentication,
    this.onComplete,
  });

  @override
  _AuthenticationWidgetState createState() => _AuthenticationWidgetState();
}

enum AuthenticationPageType { authentication, emailVerification }

class _AuthenticationWidgetState extends BasePresenter<AuthenticationWidget> implements AuthenticationPresenterView {
  AuthenticationPresenter presenter;
  AuthenticationPageType pageType;

  bool get isForcedAuthentication => widget.isForcedAuthentication;

  _AuthenticationWidgetState() {
    presenter = AuthenticationPresenter(this);
  }

  @override
  void initState() {
    pageType = widget.pageType;
    super.initState();
  }

  void onSignUpOrLogInCompleted() async {
    bool isUserVerified = await presenter.checkUserEmailVerified();
    if (isUserVerified) {
      widget.onComplete?.call();
    } else {
      setMountedState(() => pageType = AuthenticationPageType.emailVerification);
    }
  }

  void onEmailVerificationCompleted() async {
    bool isUserVerified = await presenter.checkUserEmailVerified();
    if (isUserVerified) {
      widget.onComplete?.call();
    }
  }

  void onEmailVerificationLoggedOut() {
    setMountedState(() => pageType = AuthenticationPageType.authentication);
  }

  Widget get child {
    switch (pageType) {
      case AuthenticationPageType.emailVerification:
        return EmailVerificationWidget(
          onComplete: onEmailVerificationCompleted,
          onLogout: onEmailVerificationLoggedOut,
        );
      case AuthenticationPageType.authentication:
      default:
        return _PageLayout(
          onLogInButtonPressed: () => Navigator.of(context).push(
            LogInPage(onComplete: onSignUpOrLogInCompleted),
          ),
          onSignUpButtonPressed: () => Navigator.of(context).push(
            SignUpPage(onComplete: onSignUpOrLogInCompleted),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (!isForcedAuthentication) {
            pop();
          }
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              AuthenticationPageBackground(),
              child,
            ],
          ),
        ),
      );
}

class AuthenticationButton extends StatelessWidget {
  final String text;
  final bool isDisabled;
  final VoidCallback onPressed;

  AuthenticationButton({
    @required this.text,
    @required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: isDisabled ? null : onPressed,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 56,
            color: Colors.white.withOpacity(0.3),
            child: Center(
              child: TextScaled(
                text,
                style: AppTextStyles.h5ZirkonRegular.copyWith(color: AppColors.baseColorFaded),
              ),
            ),
          ),
        ),
      );
}

class _PageLayout extends StatelessWidget {
  final VoidCallback onSignUpButtonPressed;
  final VoidCallback onLogInButtonPressed;

  const _PageLayout({
    @required this.onSignUpButtonPressed,
    @required this.onLogInButtonPressed,
  });

  Widget buildHeader(BuildContext context) => TextScaled(
        App.appName,
        style: AppTextStyles.dashboardHeaderTitle,
      );

  Widget buildDescription(BuildContext context) => TextScaled(
        localize(context, "authentication_page_description"),
        style: AppTextStyles.h5ZirkonRegular.copyWith(color: AppColors.baseColorFaded),
      );

  Widget buildSignUpButton(BuildContext context) => AuthenticationButton(
        text: localize(context, "authentication_sign_up_button"),
        onPressed: () => onSignUpButtonPressed?.call(),
      );

  Widget buildAlreadyHaveAccountRow(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextScaled(
            localize(context, "authentication_already_have_account"),
            style: AppTextStyles.h5ZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
          ),
          GestureDetector(
            onTap: onLogInButtonPressed,
            child: Container(
              height: 40,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: TextScaled(
                " " + localize(context, "log_in"),
                style: AppTextStyles.h5ZirkonRegular.copyWith(color: AppColors.baseColorFaded),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ColumnSeparator.huge,
              Padding(
                padding: const EdgeInsets.only(left: bigPadding),
                child: buildHeader(context),
              ),
              ColumnSeparator.veryHuge,
              PageTitle(
                text: localize(context, "authentication_page_title"),
                color: AppColors.baseColorFaded,
              ),
              ColumnSeparator.medium,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildDescription(context),
                    ColumnSeparator.huge,
                    buildSignUpButton(context),
                    ColumnSeparator.medium,
                    buildAlreadyHaveAccountRow(context),
                    ColumnSeparator.medium,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
