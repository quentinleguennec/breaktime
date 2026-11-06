import 'package:aebeze/assets.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class ActiveIngredientIcon extends StatefulWidget {
  final List<ActiveIngredient> cardActiveIngredients;
  final Color iconColor;
  final TextStyle textStyle;
  final VoidCallback onPressed;
  final bool showName;
  final String treatmentName;

  ActiveIngredientIcon({
    @required this.cardActiveIngredients,
    this.iconColor = Colors.white,
    this.textStyle,
    this.onPressed,
    this.showName = true,
    this.treatmentName,
  });

  @override
  _ActiveIngredientIconState createState() => _ActiveIngredientIconState();
}

class _ActiveIngredientIconState extends SafeState<ActiveIngredientIcon> with SingleTickerProviderStateMixin {
  static const double animationFadePlateauValue = 0.2;
  AnimationController animationController;
  int currentActiveIngredientIndex = 0;

  List<ActiveIngredient> get activeIngredients => widget.cardActiveIngredients;

  String get treatmentName => widget.treatmentName;

  TextStyle get textStyle => widget.textStyle;

  Color get iconColor => widget.iconColor;

  bool get showName => widget.showName;

  VoidCallback get onPressed => widget.onPressed;

  ActiveIngredient get activeIngredient =>
      (activeIngredients == null || activeIngredients.isEmpty) ? null : activeIngredients[currentActiveIngredientIndex];

  double get opacity => animationController.value < animationFadePlateauValue
      ? animationController.value / animationFadePlateauValue
      : animationController.value > (1 - animationFadePlateauValue)
          ? (1 - animationController.value) / animationFadePlateauValue
          : 1;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 8000), value: animationFadePlateauValue)
          ..addListener(refreshState)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              currentActiveIngredientIndex++;
              if (currentActiveIngredientIndex == activeIngredients.length) {
                currentActiveIngredientIndex = 0;
              }
              animationController?.forward(from: 0);
            }
          });
    if (activeIngredients != null && activeIngredients.length >= 2) {
      animationController.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: onPressed,
          child: showName && !isEmptyOrNull(activeIngredient?.name)
              ? buildActiveIngredientWithName(context)
              : buildActiveIngredient(context),
        ),
      );

  Widget buildActiveIngredient(BuildContext context) => Container(
        width: 48.0,
        height: 48.0,
        padding: EdgeInsets.only(top: treatmentName != null ? 6.0 : 16.0, left: 6.0, right: 6.0, bottom: 6.0),
        color: Colors.transparent,
        child: Image.asset(
          Assets.ingredientSmallImage(activeIngredient?.name),
          width: 36.0,
          height: 36.0,
          color: iconColor,
        ),
      );

  Widget buildActiveIngredientWithName(BuildContext context) => Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: treatmentName != null ? CrossAxisAlignment.center : CrossAxisAlignment.end,
          children: <Widget>[
            buildActiveIngredient(context),
            Padding(
              padding: EdgeInsets.only(bottom: treatmentName != null ? 0 : 10, left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (treatmentName != null)
                    TextScaled(
                      treatmentName.toUpperCase(),
                      style: textStyle ?? AppTextStyles.h7ZirkonRegular.copyWith(color: Colors.white),
                    ),
                  TextScaled(
                    activeIngredient.name,
                    style: textStyle ?? AppTextStyles.h7ZirkonRegular.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
