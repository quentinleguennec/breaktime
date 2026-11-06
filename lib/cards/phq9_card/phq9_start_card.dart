import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/phq9_card/phq9_start_card_layout.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:flutter/widgets.dart';

class PHQ9StartCard extends BasicCard {
  PHQ9StartCard(PageContext pageContext) : super(pageContext);

  static DataCard card = DataCard(
    uid: "phq9StartCard",
    type: "phq9_start",
    background: Background(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.offWhite, AppColors.lightCyan],
      ),
    ),
  );

  @override
  BasicCardState createState() => _State();
}

class _State extends BasicCardState {
  @override
  PHQ9StartCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) =>
      PHQ9StartCardLayout(widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded);
}
