import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/dashboard/treatment_animated_image.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum TreatmentListItemAlignment { left, right }

class TreatmentListItem extends StatelessWidget {
  /// The real box width and height will be computed based on those values and the actual size of the screen.
  static const double boxWidth = 375;
  static const double boxHeight = 240;
  static const double activeIngredientsPositionFromTop = 20;
  static const double titlePositionFromTop = 92;
  static const double benefitsPositionFromBottom = 24;
  static const double leftPadding = bigPadding;
  static const double rightPadding = bigPadding;
  static const double imageScaleMultiplier = 0.65;

  final Treatment treatment;
  final double screenWidth;
  final ScrollController scrollController;
  final ValueSetter<TreatmentListItemRenderBoxDataForAnimation> onSelected;
  final Animation<double> parallaxAnimation;
  final double scale;
  final TreatmentListItemAlignment boxAlignment;
  final bool isRecommended;

  TreatmentListItem({
    @required this.treatment,
    @required this.screenWidth,
    @required this.scrollController,
    @required this.onSelected,
    @required this.isRecommended,
    this.boxAlignment = TreatmentListItemAlignment.right,
    this.parallaxAnimation,
  }) : scale = screenWidth / boxWidth;

  Widget buildParallaxBox(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        height: boxHeight * scale,
        decoration: BoxDecoration(
          color: App.isDayBreak ? Colors.black : null,
          gradient: App.isDayBreak
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: treatment?.gradientColors ?? [AppColors.offWhite, AppColors.lightCyan],
                ),
        ),
        child: ParallaxBoxWithGlobalPosition(
          scrollController: scrollController,
          animation: parallaxAnimation,
          child: Image.asset(
            Assets.ingredientImage(
              treatment.activeIngredients == null || treatment.activeIngredients.isEmpty
                  ? null
                  : treatment.activeIngredients.first?.name,
            ),
            fit: BoxFit.none,
            scale: 1 / (scale * imageScaleMultiplier),
            color: App.isDayBreak ? null : stringToColor(treatment.color),
            alignment: Alignment.center,
          ),
        ),
      );

  Widget buildTitleText() => Positioned(
        top: titlePositionFromTop * scale,
        left: leftPadding * scale,
        child: _Title(treatment, scale),
      );

  Widget buildBenefitsText(BuildContext context) => Positioned(
        bottom: benefitsPositionFromBottom * scale,
        left: leftPadding * scale,
        right: rightPadding * scale,
        child: _Benefits(treatment),
      );

  Widget buildActiveIngredientText() => Positioned(
        top: activeIngredientsPositionFromTop * scale,
        left: leftPadding * scale,
        child: _ActiveIngredient(treatment),
      );

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: isRecommended ? null : const EdgeInsets.only(left: defaultPadding),

        /// Use a [LayoutBuilder] to get the correct renderBox size including the padding and margin.
        child: LayoutBuilder(
          builder: (context, size) => GestureDetector(
            onTap: () {
              final RenderBox renderBox = context.findRenderObject();
              final Offset renderBoxPosition = renderBox.localToGlobal(Offset.zero);
              TreatmentListItemRenderBoxDataForAnimation data = TreatmentListItemRenderBoxDataForAnimation(
                treatment: treatment,
                renderBoxPosition: renderBoxPosition,
                renderBoxSize: renderBox.size,
                parallaxDisplacement: ParallaxBoxWithGlobalPosition.computeParallaxDisplacement(renderBox, context),
                isRecommended: isRecommended,
              );
              onSelected(data);
            },
            child: ClipRect(
              child: Stack(
                children: <Widget>[
                  buildParallaxBox(context),
                  buildActiveIngredientText(),
                  buildTitleText(),
                  buildBenefitsText(context),
                ],
              ),
            ),
          ),
        ),
      );
}

class TreatmentListItemInflateAnimatedWidget extends AnimatedWidget {
  static const double titlePositionFromTopAfterInflation = 50.0;

  final TreatmentListItemRenderBoxDataForAnimation animationData;
  final double screenWidth;
  final Animation<double> animation;
  final double scale;

  TreatmentListItemInflateAnimatedWidget({
    @required this.animationData,
    @required this.screenWidth,
    @required this.animation,
  })  : scale = screenWidth / TreatmentListItem.boxWidth,
        super(listenable: animation);

  Widget buildBox(BuildContext context) => Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: App.isDayBreak ? Colors.black : null,
          gradient: App.isDayBreak
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: animationData?.treatment?.gradientColors ?? [AppColors.offWhite, AppColors.lightCyan],
                ),
        ),
        child: Opacity(
          opacity: 1.0 - animation.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(0.0, animationData.parallaxDisplacement, 0.0),
            child: Image.asset(
              Assets.ingredientImage(animationData.treatment.activeIngredients?.first?.name),
              fit: BoxFit.none,
              scale: 1 / (scale * TreatmentListItem.imageScaleMultiplier),
              color: App.isDayBreak ? null : stringToColor(animationData.treatment.color),
              alignment: Alignment.center,
            ),
          ),
        ),
      );

  Widget buildTitleText() => Positioned(
        top: TreatmentListItem.titlePositionFromTop * scale,
        left: TreatmentListItem.leftPadding * scale,
        child: Opacity(
          opacity: 1.0 - animation.value,
          child: _Title(animationData.treatment, scale),
        ),
      );

  Widget buildBenefitsText(BuildContext context) => Positioned(
        bottom: TreatmentListItem.benefitsPositionFromBottom * scale,
        left: TreatmentListItem.leftPadding * scale,
        right: TreatmentListItem.rightPadding * scale,
        child: Opacity(
          opacity: 1.0 - animation.value,
          child: _Benefits(animationData.treatment),
        ),
      );

  Widget buildActiveIngredientText() => Positioned(
        top: TreatmentListItem.activeIngredientsPositionFromTop * scale,
        left: TreatmentListItem.leftPadding * scale,
        child: Opacity(
          opacity: 1.0 - animation.value,
          child: _ActiveIngredient(animationData.treatment),
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          buildBox(context),
          buildActiveIngredientText(),
          buildTitleText(),
          buildBenefitsText(context),
        ],
      );
}

class _Title extends StatelessWidget {
  final Treatment treatment;
  final double scale;

  const _Title(
    this.treatment,
    this.scale,
  );

  @override
  Widget build(BuildContext context) => TextScaled(
        treatment.name ?? "",
        style: AppTextStyles.startCardTitle,
        textScaleFactor: scale,
      );
}

class _Benefits extends StatelessWidget {
  final Treatment treatment;

  const _Benefits(this.treatment);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < treatment.benefits.length && i < 3; i++) ...[
            TextScaled(
              treatment.benefits[i],
              style: AppTextStyles.dashboardTreatmentListItemBenefits,
            ),
            if (i < treatment.benefits.length - 1 && i < 2) Padding(padding: const EdgeInsets.only(top: 2)),
          ],
        ],
      );
}

class _ActiveIngredient extends StatelessWidget {
  final Treatment treatment;

  const _ActiveIngredient(this.treatment);

  @override
  Widget build(BuildContext context) => TextScaled(
        treatment.activeIngredients == null || treatment.activeIngredients.isEmpty
            ? ""
            : treatment.activeIngredients.first.name.toUpperCase(),
        style: AppTextStyles.dashboardTreatmentListItemActiveIngredient,
      );
}
