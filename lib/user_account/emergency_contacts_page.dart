import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/user_account/emergency_contacts_page_presenter.dart';
import 'package:aebeze/user_account/widgets/page_background.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/sub_category_header.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPage extends PopupRoute<Null> {
  final bool isPrivacyPage;

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

  EmergencyContactsPage({@required this.isPrivacyPage});

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
      _PageLayout(isPrivacyPage: isPrivacyPage);
}

class _PageLayout extends StatefulWidget {
  final bool isPrivacyPage;

  _PageLayout({@required this.isPrivacyPage});

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements EmergencyContactsPagePresenterView {
  static const privacyPolicyUrl = "https://www.aebeze.com/daybreak-privacy-policy/";
  static const int _numberOfContacts = 4;
  EmergencyContactsPagePresenter presenter;

  bool get isPrivacyPage => widget.isPrivacyPage;

  _PageLayoutState() {
    presenter = EmergencyContactsPagePresenter(this);
  }

  Widget getDescription(BuildContext context) => TextScaled(
        localize(context, "emergency_contacts_page_description"),
        style: AppTextStyles.h3ZirkonRegular.copyWith(color: AppColors.whiteFaded),
      );

  Widget getFooter(BuildContext context) => TextScaled(
        localize(context, "emergency_contacts_page_footer"),
        style: AppTextStyles.bodyZirkonRegular.copyWith(color: AppColors.whiteFaded),
      );

  Widget getContacts(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 1; i <= _numberOfContacts; i++) getContact(context, i),
        ],
      );

  Widget getContact(BuildContext context, int index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getContactTitle(
            context,
            "emergency_contacts_page_${index}_title",
          ),
          getContactNumber(
            context,
            "emergency_contacts_page_${index}_number",
            localizedAdditionalText: index == 1 ? "emergency_contacts_page_1_additional_text" : null,
          ),
          if (index != _numberOfContacts) ColumnSeparator.medium,
        ],
      );

  Widget getContactTitle(BuildContext context, String localizedString) => TextScaled(
        localize(context, localizedString),
        style: AppTextStyles.h4ZirkonRegular.copyWith(
          color: AppColors.whiteFaded,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget getContactNumber(BuildContext context, String localizedNumber, {String localizedAdditionalText}) => RichText(
        textScaleFactor: MediaQuery.textScaleFactorOf(context).clamp(0.0, maxTextScaleFactor),
        text: TextSpan(
          text: localize(context, localizedNumber),
          style: AppTextStyles.h4ZirkonRegular.copyWith(color: AppColors.tealish),
          recognizer: TapGestureRecognizer()..onTap = () => presenter.openPhoneApp(localize(context, localizedNumber)),
          children: <TextSpan>[
            if (localizedAdditionalText != null)
              TextSpan(
                text: localize(context, localizedAdditionalText),
                style: AppTextStyles.h4ZirkonRegular.copyWith(color: AppColors.whiteFaded),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    int count = 0;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          UserAccountPageBackground(),
          Column(
            children: [
              NavigationAppBarOverlay(
                withInvertedColor: !App.isDayBreak,
                isCancel: false,
              ),
              ColumnSeparator.veryBig,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      PageTitle(text: localize(context, "emergency_contacts_page_title")),
                      ColumnSeparator.huge,
                      Padding(
                        padding: EdgeInsets.only(
                          left: defaultPadding,
                          right: defaultPadding,
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SubCategoryHeader(title: localize(context, "emergency_contacts_page_sub_title")),
                            ColumnSeparator.medium,
                            getDescription(context),
                            ColumnSeparator.big,
                            getContacts(context),
                            ColumnSeparator.big,
                            getFooter(context),
                            ColumnSeparator.veryBig,
                            if (isPrivacyPage)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => launch(privacyPolicyUrl),
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: const EdgeInsets.all(defaultPadding),
                                      child: TextScaled(
                                        localize(context, "button_more").toUpperCase(),
                                        style: AppTextStyles.bodyLightZirkonBook.copyWith(color: AppColors.whiteFaded),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.popUntil(
                                      context,
                                      (route) {
                                        return count++ == 2;
                                      },
                                    ),
                                    child: Container(
                                      color: Colors.transparent,
                                      padding: const EdgeInsets.all(defaultPadding),
                                      child: TextScaled(
                                        localize(context, "button_done").toUpperCase(),
                                        style: AppTextStyles.bodyLightZirkonBook.copyWith(color: AppColors.whiteFaded),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ColumnSeparator.huge,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
