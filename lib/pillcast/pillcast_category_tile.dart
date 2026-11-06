import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PillcastCategoryListItem extends StatelessWidget {
  final PillcastAudioTreatment treatment;
  final Animation animation;
  final double animationTranslationValue;
  final VoidCallback onTap;

  const PillcastCategoryListItem({
    @required this.treatment,
    @required this.animation,
    @required this.animationTranslationValue,
    this.onTap,
  });

  Widget buildImage() => Container(
        width: 35,
        height: 35,
        child: Image(
          color: Colors.white,
          fit: BoxFit.cover,
          image: AssetImage(Assets.ingredientSmallImage(treatment.activeIngredient)),
        ),
      );

  Widget buildHeader(BuildContext context) => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  Assets.iconPillcastTrack,
                  width: 18,
                  height: 12,
                  color: AppColors.whiteVeryFaded,
                ),
              ),
              TextScaled(
                localize(context, "pillcast_audio_program"),
                style: AppTextStyles.smallText,
              ),
            ],
          ),
          ColumnSeparator.tinyPlus,
          SeparatorLine(),
        ],
      );

  Widget buildTitle(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextScaled(
            capitalizeWord(treatment.type),
            style: AppTextStyles.h3SmallProtoGroteskLight.copyWith(color: AppColors.whiteFaded),
          ),
          buildImage(),
        ],
      );

  Widget buildDescription(BuildContext context) => TextScaled(
        treatment.getDescriptionText(context),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyZirkonRegular.copyWith(color: Colors.white.withOpacity(0.8)),
      );

  @override
  Widget build(BuildContext context) => AnimatedRevealTransitionWidget(
        animation: animation,
        translationValue: animationTranslationValue,
        direction: AnimatedRevealTransitionWidgetDirection.vertical,
        child: GestureDetector(
          child: Container(
            margin: const EdgeInsets.only(bottom: smallPadding),
            padding: const EdgeInsets.only(
              left: bigPadding,
              right: bigPadding,
              bottom: bigPadding,
              top: smallPadding,
            ),
            decoration: AppDecorations.transparentBox,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildHeader(context),
                ColumnSeparator.big,
                buildTitle(context),
                ColumnSeparator.tinyPlus,
                buildDescription(context),
              ],
            ),
          ),
          onTap: onTap,
        ),
      );
}
