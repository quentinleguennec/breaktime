import 'dart:ui';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../theme.dart';
import 'safe_state.dart';

class RatingButtons extends StatefulWidget {
  final ValueChanged<int> onNumberTapped;
  final int rating;

  RatingButtons({
    Key key,
    @required this.onNumberTapped,
    this.rating,
  });

  @override
  _RatingButtonsState createState() => _RatingButtonsState();
}

class _RatingButtonsState extends SafeState<RatingButtons> with TickerProviderStateMixin {
  static const double spaceBetweenButtons = 16;
  static const List<int> numbers = [1, 2, 3, 4, 5];

  int selectedIndex;
  List<AnimationController> buttonsAnimationControllers;

  ValueChanged<int> get onNumberTapped => widget.onNumberTapped;

  int get rating => widget.rating;

  @override
  void initState() {
    buttonsAnimationControllers = List.generate(
      numbers.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 200)),
    );
    super.initState();
  }

  @override
  void dispose() {
    buttonsAnimationControllers?.forEach((controller) => controller?.dispose());
    super.dispose();
  }

  Widget getButton(int index) => _RatingButton(
        number: numbers[index],
        animation: buttonsAnimationControllers[index],
        textUnder: index == 0
            ? localize(context, "end_card_rating_didnt_help").toUpperCase()
            : index == numbers.length - 1 ? localize(context, "end_card_rating_did_help").toUpperCase() : null,
        onTap: () {
          if (selectedIndex != index) {
            if (selectedIndex != null) {
              buttonsAnimationControllers[selectedIndex].reverse();
            }
            selectedIndex = index;
            buttonsAnimationControllers[index].forward();
            onNumberTapped(numbers[index]);
          }
        },
      );

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: spaceBetweenButtons,
        runSpacing: 0,
        children: [
          for (int i = 0; i < numbers.length; i++) getButton(i),
        ],
      );
}

class _RatingButton extends AnimatedWidget {
  final VoidCallback onTap;
  final int number;
  final Animation animation;
  final String textUnder;

  _RatingButton({
    @required this.number,
    @required this.onTap,
    @required this.animation,
    this.textUnder,
  }) : super(listenable: animation);

  double get checkMarkOpacity => (animation.value - 0.5).clamp(0.0, 0.5) * 2.0;

  double get numberOpacity => 0.95 * (1.0 - (animation.value * 2.0).clamp(0.0, 1.0));

  double get backgroundOpacity => lerpDouble(0.12, App.isDayBreak ? 0.95 : 0.6, animation.value);

  Widget get background => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(backgroundOpacity),
          shape: BoxShape.circle,
        ),
      );

  Widget get numberText => TextScaled(
        number.toString(),
        textAlign: TextAlign.center,
        style: AppTextStyles.h5ZirkonRegular.copyWith(
          color: AppTextStyles.h5ZirkonRegular.color.withOpacity(numberOpacity),
        ),
      );

  Widget get checkMark => Image.asset(
        Assets.pillcastCheckMark,
        width: 18.0,
        height: 12.0,
        color: Colors.black.withOpacity(checkMarkOpacity),
      );

  double getSize(BuildContext context) =>
      (MediaQuery.of(context).size.width -
          2 * bigPadding -
          _RatingButtonsState.spaceBetweenButtons * (_RatingButtonsState.numbers.length - 1)) /
      _RatingButtonsState.numbers.length;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) => Container(
                width: getSize(context),
                height: getSize(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment(0.5, 0.5),
                      child: background,
                    ),
                    numberText,
                    checkMark,
                  ],
                ),
              ),
            ),
            if (!isEmptyOrNull(textUnder)) ...[
              ColumnSeparator.tinyPlus,
              TextScaled(
                textUnder,
                style: AppTextStyles.h7ZirkonRegular.copyWith(color: AppColors.baseColorVeryFaded),
              ),
            ],
          ],
        ),
      );
}
