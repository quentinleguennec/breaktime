import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double navigationButtonIconSize = 35;

class BottomNavigationButton extends StatelessWidget {
  /// MediaQuery.of(context).padding.bottom isalso added to this baseHeight.
  static const double baseHeight = 90;

  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  BottomNavigationButton({
    this.text,
    this.color = Colors.black,
    this.textColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          height: baseHeight + MediaQuery.of(context).padding.bottom,
          color: color,
          child: Center(
            child: TextScaled(
              text,
              style: AppTextStyles.h5ZirkonRegular.copyWith(color: textColor),
            ),
          ),
        ),
      );
}

class BackNavigationButton extends StatelessWidget {
  final bool withInvertedColor;
  final VoidCallback onTap;

  BackNavigationButton({this.withInvertedColor = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: defaultIconTapSize,
          height: defaultIconTapSize,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Image.asset(
            Assets.iconChevronInCircle,
            width: navigationButtonIconSize,
            height: navigationButtonIconSize,
            color: withInvertedColor ? AppColors.invertedColor : AppColors.baseColor,
          ),
        ),
      );
}

class CancelNavigationButton extends StatelessWidget {
  final bool withInvertedColor;
  final VoidCallback onTap;

  CancelNavigationButton({this.withInvertedColor = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: defaultIconTapSize,
          height: defaultIconTapSize,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Image.asset(
            Assets.iconCrossInCircle,
            width: navigationButtonIconSize,
            height: navigationButtonIconSize,
            color: withInvertedColor ? AppColors.invertedColor : AppColors.baseColor,
          ),
        ),
      );
}
