import 'dart:ui';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PageTitle extends StatelessWidget {
  final String text;
  final Color color;
  final EdgeInsets padding;

  PageTitle({
    @required this.text,
    this.padding = const EdgeInsets.symmetric(horizontal: bigPadding),
    this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: TextScaled(
          text,
          textScaleFactor: 1,
          style: color == null ? AppTextStyles.bigTitle : AppTextStyles.bigTitle.copyWith(color: color),
        ),
      );
}
