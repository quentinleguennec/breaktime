import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/phq9_card/phq9_result_card_layout.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:flutter/widgets.dart';

class PHQ9ResultCard extends BasicCard {
  final ValueGetter<int> scoreGetter;

  static DataCard getCard(String uid) => DataCard(
        uid: uid,
        type: "phq9_result",
        background: Background(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.offWhite, AppColors.lightCyan],
          ),
        ),
      );

  PHQ9ResultCard(PageContext pageContext, this.scoreGetter) : super(pageContext);

  @override
  BasicCardState createState() => _State(scoreGetter);
}

class _State extends BasicCardState {
  final ValueGetter<int> scoreGetter;

  _State(this.scoreGetter);

  @override
  PHQ9ResultCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) => PHQ9ResultCardLayout(
      widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded, scoreGetter);
}
