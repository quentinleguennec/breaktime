import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OrSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TextScaled(
        localize(context, 'authentication_or_separator').toUpperCase(),
        style: AppTextStyles.h6ZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
      );
}
