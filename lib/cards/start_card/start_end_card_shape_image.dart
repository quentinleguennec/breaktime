import 'package:aebeze/app.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/start_card/start_card_layout.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/reveal_container.dart';
import 'package:flutter/material.dart';

class StartEndCardShapeImage extends StatelessWidget {
  final Treatment treatment;
  final Animation animation;

  StartEndCardShapeImage({@required this.treatment, @required this.animation});

  @override
  Widget build(BuildContext context) => RevealContainer(
        animation,
        child: Transform.scale(
          scale: StartCardLayout.shapeScaleMultiplier,
          child: Image.asset(
            Assets.ingredientImage(
                isEmptyOrNull(treatment.activeIngredients) ? null : treatment.activeIngredients.first.name),
            width: MediaQuery.of(context).size.width,
            color: App.isDayBreak ? null : stringToColor(treatment.color),
          ),
        ),
      );
}
