import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/widgets/next_button.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/user_account/emergency_contacts_page.dart';
import 'package:aebeze/user_account/widgets/page_background.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/sub_category_header.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PrivacyPolicyPage extends PopupRoute<Null> {
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

  PrivacyPolicyPage();

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
      PrivacyPage();
}

class PrivacyPage extends StatelessWidget {
  Widget getTitle(BuildContext context) => Text(
        localize(context, "privacy_page_title"),
        style: AppTextStyles.daybreakPHQ9Title,
        textScaleFactor: 1,
      );

  Widget getDescription(BuildContext context) => TextScaled(
        localize(context, "privacy_page_sub_title_2"),
        style: AppTextStyles.h3ZirkonRegular.copyWith(color: AppColors.whiteFaded),
      );

  Widget getMainText(BuildContext context, String localizedString) => TextScaled(
        localize(context, localizedString),
        style: AppTextStyles.bodyZirkonRegular.copyWith(color: AppColors.whiteFaded),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
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
                        PageTitle(text: localize(context, "privacy_page_title")),
                        ColumnSeparator.huge,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SubCategoryHeader(title: localize(context, "privacy_page_sub_title")),
                              ColumnSeparator.medium,
                              getDescription(context),
                              ColumnSeparator.big,
                              getMainText(context, "privacy_page_description"),
                              ColumnSeparator.big,
                              getMainText(context, "privacy_page_main_text"),
                              ColumnSeparator.big,
                              getMainText(context, "privacy_page_emergency_contacts_text"),
                              ColumnSeparator.big,
                              getMainText(context, "privacy_page_footer"),
                              ColumnSeparator.big,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  NextButton(
                                    onPressed: () =>
                                        Navigator.push(context, EmergencyContactsPage(isPrivacyPage: true)),
                                    color: AppColors.whiteFaded,
                                    padding: const EdgeInsets.only(left: defaultPadding),
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
