import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ActiveIngredientText extends StatelessWidget {
  final List<ActiveIngredient> activeIngredients;
  final Color color;

  ActiveIngredientText({
    @required this.activeIngredients,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) => TextScaled(
        activeIngredients == null || activeIngredients.isEmpty ? "" : activeIngredients.first.name.toUpperCase(),
        style: AppTextStyles.medicinal.copyWith(color: color),
        maxLines: 1,
      );
}
