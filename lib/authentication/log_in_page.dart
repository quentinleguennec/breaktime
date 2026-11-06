import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/authentication/authentication_page.dart';
import 'package:aebeze/authentication/log_in_presenter.dart';
import 'package:aebeze/authentication/widgets/or_separator.dart';
import 'package:aebeze/authentication/widgets/page_background.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/text_input_field.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LogInPage extends MaterialPageRoute<Null> {
  final VoidCallback onComplete;
  final bool resetUserCredentials;

  LogInPage({
    @required this.onComplete,
    this.resetUserCredentials = false,
  }) : super(
          builder: (_) => LogInWidget(
            resetUserCredentials: resetUserCredentials,
            onComplete: onComplete,
          ),
          settings: TrackingService.loginPage,
        );
}

class LogInWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final bool resetUserCredentials;

  LogInWidget({
    @required this.onComplete,
    this.resetUserCredentials = false,
  });

  @override
  _LogInWidgetState createState() => _LogInWidgetState();
}

class _LogInWidgetState extends BasePresenter<LogInWidget> implements LogInPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LogInPresenter presenter;
  String email;
  String emailError;
  String password;
  String passwordError;
  FocusNode focus = FocusNode();

  _LogInWidgetState() {
    presenter = LogInPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    if (widget.resetUserCredentials) {
      presenter.resetUserCredentials(context);
    }
  }

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  void logIn() {
    emailError = getEmailError(email, context);
    passwordError = getPasswordError(password, context);
    if (passwordError == null && emailError == null) {
      presenter.logInWithEmail(email, password);
    }
    refreshState();
  }

  @override
  void onLogInSuccess() {
    if (widget.onComplete == null) {
      pop();
      pop();
      return;
    }
    pop();
    widget.onComplete();
  }

  Widget get facebookButton => AuthenticationButton(
        text: localize(context, 'log_in_with_facebook'),
        isDisabled: inProgress,
        onPressed: () {
          presenter.logInWithFacebook();
          refreshState();
        },
      );

  Widget get emailField => EmailInputField(
        onChanged: (text) => email = text,
        errorText: emailError,
        onNext: () => FocusScope.of(context).requestFocus(focus),
      );

  Widget get passwordField => PasswordInputField(
        onChanged: (text) => password = text,
        errorText: passwordError,
        focus: focus,
        onNext: logIn,
      );

  Widget get loginButton => AuthenticationButton(
        text: localize(context, "log_in_with_email"),
        isDisabled: inProgress,
        onPressed: logIn,
      );

  Widget get resetPasswordButton => GestureDetector(
        child: Container(
          color: Colors.transparent,
          child: TextScaled(
            localize(context, "forgot_your_password"),
            style: AppTextStyles.captionSmallZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
          ),
        ),
        onTap: presenter.openResetPasswordPagePage,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            AuthenticationPageBackground(),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: NavigationAppBarOverlay(isCancel: false),
                  ),
                  ColumnSeparator.veryBig,
                  PageTitle(
                    text: localize(context, "authentication_login_page_title"),
                    color: AppColors.baseColorFaded,
                  ),
                  ColumnSeparator.veryBig,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        emailField,
                        ColumnSeparator.big,
                        passwordField,
                        ColumnSeparator.medium,
                        resetPasswordButton,
                        ColumnSeparator.big,
                        loginButton,
                        ColumnSeparator.medium,
                        if (!App.isDayBreak) ...[
                          Center(child: OrSeparator()),
                          ColumnSeparator.medium,
                          facebookButton,
                          ColumnSeparator.medium,
                        ],
                        ColumnSeparator.medium,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
