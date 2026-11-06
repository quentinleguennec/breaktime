import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/start_card/start_card_layout.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StartCard extends BasicCard {
  final bool preventTransitionAnimation;

  static DataCard getCard(Treatment treatment, BuildContext context) => DataCard(
        uid: "startCard",
        type: "start",
        description: treatment.directions,
        activeIngredients: treatment.activeIngredients,
        title: localize(context, "start_card_menu_title"),
        background: Background(
          gradient: App.isDayBreak
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: treatment?.gradientColors ?? [AppColors.offWhite, AppColors.lightCyan],
                ),
        ),
      );

  StartCard({
    @required pageContext,
    this.preventTransitionAnimation = false,
  }) : super(pageContext);

  @override
  _StartCardState createState() => _StartCardState(preventTransitionAnimation: preventTransitionAnimation);
}

class _StartCardState extends BasicCardState {
  final bool preventTransitionAnimation;

  _StartCardState({this.preventTransitionAnimation = false});

  Widget buildCardLayout(BasicCard widget, CardAnimator animator) => StartCardLayout(
        widget.pageContext,
        animator,
        super.onBackgroundVideoLoaded,
        super.onBackgroundImageLoaded,
        preventTransitionAnimation: preventTransitionAnimation,
      );
}
