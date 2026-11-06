import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DashboardBottomNavBar extends StatefulWidget {
  static const double height = 95;

  final VoidCallback onCheckInPressed;
  final VoidCallback onHistoryPressed;
  final VoidCallback onPillcastPressed;
  final VoidCallback onUserAccountPressed;

  const DashboardBottomNavBar({
    this.onCheckInPressed,
    this.onHistoryPressed,
    this.onPillcastPressed,
    this.onUserAccountPressed,
  });

  @override
  _DashboardBottomNavBarState createState() => _DashboardBottomNavBarState();
}

class _DashboardBottomNavBarState extends BasePresenter<DashboardBottomNavBar> with SingleTickerProviderStateMixin {
  Widget get checkInButton => _TextIconButton(
        icon: Image.asset(
          Assets.iconCheckIn,
          color: AppColors.baseColor,
          width: 30.0,
          height: 30.0,
        ),
        text: localize(context, "dashboard_icon_check_in"),
        onPressed: widget.onCheckInPressed,
      );

  Widget get historyButton => _TextIconButton(
        icon: Image.asset(
          Assets.iconHistory,
          color: AppColors.baseColor,
          width: 30.0,
          height: 30.0,
        ),
        text: localize(context, "dashboard_icon_history"),
        onPressed: widget.onHistoryPressed,
      );

  Widget get pillcastButton => _TextIconButton(
        icon: Image.asset(
          Assets.iconPillcast,
          color: AppColors.baseColor,
          width: 30.0,
          height: 30.0,
        ),
        text: localize(context, "dashboard_icon_pillcast"),
        onPressed: widget.onPillcastPressed,
      );

  Widget get userAccountButton => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: _TextIconButton(
          icon: Image.asset(
            Assets.iconUserAccount,
            width: 25.0,
            height: 25.0,
          ),
          text: localize(context, "dashboard_icon_user_account"),
          onPressed: widget.onUserAccountPressed,
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        height: DashboardBottomNavBar.height,
        decoration: BoxDecoration(
          color: AppColors.invertedColor,
          boxShadow: [
            if (!App.isDayBreak)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 7,
                offset: const Offset(0, -4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            checkInButton,
            historyButton,
            pillcastButton,
            userAccountButton,
          ],
        ),
      );
}

class _TextIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String text;
  final Color textColor;

  _TextIconButton({
    @required this.icon,
    this.text,
    this.onPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed == null ? null : () => onPressed(),
        child: Container(
          constraints: BoxConstraints(minWidth: defaultIconTapSize, minHeight: defaultIconTapSize),
          padding: const EdgeInsets.only(top: 16),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              icon,
              ColumnSeparator.tiny,
              TextScaled(text, style: AppTextStyles.iconText.copyWith(color: textColor ?? AppColors.baseColor)),
            ],
          ),
        ),
      );
}
