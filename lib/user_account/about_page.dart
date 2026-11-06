import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/user_account/about_presenter.dart';
import 'package:aebeze/user_account/widgets/page_background.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/sub_category_header.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutPage extends MaterialPageRoute<Null> {
  AboutPage() : super(builder: (_) => _PageLayout(), settings: TrackingService.aboutPage);
}

class _PageLayout extends StatefulWidget {
  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements AboutPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AboutPresenter presenter;

  _PageLayoutState() {
    presenter = AboutPresenter(this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
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
                        PageTitle(text: localize(context, "about_page_title")),
                        ColumnSeparator.huge,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                          child: Column(
                            children: <Widget>[
                              SubCategoryHeader(title: localize(context, "about_page_sub_title")),
                              ColumnSeparator.medium,
                              TextScaled(
                                localize(context, "about_page_main_text"),
                                style: AppTextStyles.bodyZirkonRegular.copyWith(color: AppColors.whiteFaded),
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

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;
}
