import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/authentication/authentication_page.dart';
import 'package:aebeze/authentication/reset_password_presenter.dart';
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

class ResetPasswordPage extends MaterialPageRoute<Null> {
  ResetPasswordPage()
      : super(
          builder: (_) => _PageLayout(),
          settings: TrackingService.resetPasswordPage,
        );
}

class _PageLayout extends StatefulWidget {
  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements ResetPasswordPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ResetPasswordPresenter presenter;
  String email;
  String emailError;

  _PageLayoutState() {
    presenter = ResetPasswordPresenter(this);
  }

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  void resetPassword() {
    emailError = getEmailError(email, context);
    if (emailError == null) {
      presenter.resetPassword(email);
    }
    refreshState();
  }

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
                    text: localize(context, "authentication_reset_password_page_title"),
                    color: AppColors.baseColorFaded,
                  ),
                  ColumnSeparator.veryBig,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        EmailInputField(
                          onChanged: (text) => email = text,
                          errorText: emailError,
                          onNext: resetPassword,
                          action: TextInputAction.done,
                        ),
                        ColumnSeparator.medium,
                        TextScaled(
                          localize(context, "authentication_password_reset_description"),
                          style: AppTextStyles.captionSmallZirkonRegular.copyWith(color: AppColors.blackVeryFaded),
                        ),
                        ColumnSeparator.big,
                        AuthenticationButton(
                          text: localize(context, "authentication_reset_password_button"),
                          isDisabled: inProgress,
                          onPressed: resetPassword,
                        ),
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
