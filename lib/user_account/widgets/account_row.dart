import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AccountRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double height;
  final double horizontalPadding;
  final double horizontalMargin;

  AccountRow({
    this.title,
    this.onTap,
    this.height = 56.0,
    this.horizontalPadding = defaultPadding,
    this.horizontalMargin = defaultPadding,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Container(
          margin: EdgeInsets.only(left: horizontalMargin, right: horizontalMargin, bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          alignment: Alignment.centerLeft,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
          ),
          child: TextScaled(
            title,
            style: AppTextStyles.bodyZirkonRegular.copyWith(
              color: App.isDayBreak ? AppTextStyles.bodyZirkonRegular.color : AppColors.whiteFaded,
            ),
          ),
        ),
        onTap: onTap,
      );
}
