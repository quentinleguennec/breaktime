import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/notifications/notification_manager_page_presenter.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/user_account/widgets/page_background.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/page_title.dart';
import 'package:aebeze/widgets/sub_category_header.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:aebeze/widgets/toggle.dart';
import 'package:flutter/material.dart';

class NotificationManagerPage extends MaterialPageRoute<Null> {
  NotificationManagerPage() : super(builder: (_) => _PageLayout(), settings: TrackingService.notificationManagerPage);
}

class _PageLayout extends StatefulWidget {
  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout>
    with TickerProviderStateMixin
    implements NotificationManagerPagePresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationManagerPagePresenter presenter;

  _PageLayoutState() {
    presenter = NotificationManagerPagePresenter(this);
  }

  @override
  void initState() {
    super.initState();
    presenter.loadUserNotificationPref().then((_) => refreshState());
  }

  void onCrossButtonPressed() => pop();

  Widget get summary => TextScaled(
        localize(context, 'notification_manager_body'),
        style: AppTextStyles.bodyZirkonRegular.copyWith(color: AppColors.whiteFaded),
      );

  Widget get toggleAndText => Row(
        children: <Widget>[
          Expanded(
            child: TextScaled(
              localize(context, "notification_manager_get_notified"),
              style: AppTextStyles.bodyZirkonRegular.copyWith(color: AppColors.whiteFaded),
            ),
          ),
          Toggle(
            value: presenter.areNotificationsOn,
            onChanged: (bool newValue) => presenter.onNotificationPrefChanged(newValue).then((_) => refreshState()),
          ),
        ],
      );

  Widget get testButton => Row(
        children: <Widget>[
          Expanded(
            child: TextScaled(
              "Test Notification",
              style: AppTextStyles.bodyZirkonRegular.copyWith(color: AppColors.whiteFaded),
            ),
          ),
          FlatButton(
            child: Text(
              "Trigger Notification",
              style: AppTextStyles.bodyZirkonRegular.copyWith(color: Colors.black),
            ),
            color: Colors.white.withOpacity(0.7),
            onPressed: () => presenter.scheduleTestNotification(),
          )
        ],
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          pop();
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              UserAccountPageBackground(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NavigationAppBarOverlay(
                    withInvertedColor: !App.isDayBreak,
                    isCancel: false,
                  ),
                  ColumnSeparator.veryBig,
                  PageTitle(text: localize(context, "notification_manager_title")),
                  ColumnSeparator.huge,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: Column(
                      children: <Widget>[
                        SubCategoryHeader(title: localize(context, "notification_manager_sub_title")),
                        ColumnSeparator.medium,
                        summary,
                        ColumnSeparator.big,
                        toggleAndText,
                        if (App.inDebugMode) ...[
                          ColumnSeparator.huge,
                          testButton,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
