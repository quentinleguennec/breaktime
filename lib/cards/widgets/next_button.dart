import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final Color color;

  NextButton({
    @required this.onPressed,
    this.padding,
    this.color,
  });

  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: padding,
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextScaled(
                localize(context, "button_next").toUpperCase(),
                style: color == null
                    ? AppTextStyles.bodyLightZirkonBook
                    : AppTextStyles.bodyLightZirkonBook.copyWith(color: color),
                maxLines: 2,
              ),
              IgnorePointer(
                child: ArrowIconButton(
                  quarterTurns: 2,
                  color: color ?? AppColors.baseColor,
                ),
              ),
            ],
          ),
        ),
      );
}
