import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/authentication/authentication_page.dart';
import 'package:aebeze/authentication/email_verification_presenter.dart';
import 'package:aebeze/authentication/widgets/or_separator.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmailVerificationPage extends MaterialPageRoute<Null> {
  EmailVerificationPage()
      : super(
          builder: (context) => EmailVerificationWidget(
            onComplete: () => Navigator.of(context).pop(),
            onLogout: () => Navigator.of(context).pop(),
          ),
        );
}

class EmailVerificationWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onLogout;

  EmailVerificationWidget({
    @required this.onComplete,
    this.onLogout,
  });

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<EmailVerificationWidget>
    with WidgetsBindingObserver
    implements EmailVerificationPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  EmailVerificationPresenter presenter;

  _PageLayoutState() {
    presenter = EmailVerificationPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      presenter.recheckUserVerified().then((isVerified) {
        if (isVerified) {
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Image.asset(
                Assets.iconEnvelope,
                width: 80.0,
                height: 55.0,
                color: AppColors.baseColorFaded,
              ),
            ),
            ColumnSeparator.medium,
            PageTitle(
              text: localize(context, "check_your_inbox"),
              color: AppColors.baseColorFaded,
            ),
            ColumnSeparator.big,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: smallPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 70.0),
                    child: TextScaled(
                      localize(context, "check_inbox_text"),
                      style: AppTextStyles.captionZirkonRegular.copyWith(color: AppColors.baseColorFaded),
                    ),
                  ),
                  ColumnSeparator.big,
                  TextScaled(
                    localize(context, "authentication_not_received_link"),
                    style: AppTextStyles.captionSmallZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
                    textAlign: TextAlign.start,
                  ),
                  ColumnSeparator.medium,
                  AuthenticationButton(
                    text: localize(context, "authentication_resend_verification_email_button"),
                    onPressed: () => presenter.sendVerificationEmail(context),
                  ),
                  ColumnSeparator.medium,
                  Center(child: OrSeparator()),
                  ColumnSeparator.medium,
                  AuthenticationButton(
                    text: localize(context, "authentication_verification_email_not_you_button"),
                    onPressed: () => presenter.logout().then((_) => widget.onLogout?.call()),
                  ),
                  ColumnSeparator.big,
                  Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)),
                ],
              ),
            ),
          ],
        ),
      );
}
