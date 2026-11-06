import 'package:aebeze/app.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/end_card/end_card_layout.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EndCard extends BasicCard {
  final Function onCommentInputChanged;
  final Function onRatingChanged;

  static DataCard getCard(Treatment treatment, BuildContext context) => DataCard(
        uid: "endCard",
        type: "end",
        activeIngredients: [],
        duration: const Duration(milliseconds: 0),
        background: Background(
          color: App.isDayBreak ? colorToString(Colors.black) : null,
          gradient: App.isDayBreak
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: treatment?.gradientColors ?? [AppColors.offWhite, AppColors.lightCyan],
                ),
        ),
      );

  EndCard(pageContext, this.onCommentInputChanged, this.onRatingChanged) : super(pageContext);

  @override
  _EndCardState createState() => _EndCardState(onCommentInputChanged, onRatingChanged);
}

class _EndCardState extends BasicCardState {
  final Function onCommentInputChanged;
  final Function onRatingChanged;

  _EndCardState(this.onCommentInputChanged, this.onRatingChanged);

  Widget buildCardLayout(
    BasicCard widget,
    CardAnimator animator,
  ) =>
      EndCardLayout(
        widget.pageContext,
        animator,
        super.onBackgroundVideoLoaded,
        super.onBackgroundImageLoaded,
        onCommentInputChanged,
        onRatingChanged,
      );
}
