import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/error_card_layout.dart';

class ErrorCard extends BasicCard {
  ErrorCard(PageContext pageContext) : super(pageContext);

  @override
  BasicCardState createState() => _ErrorCardState();
}

class _ErrorCardState extends BasicCardState {
  @override
  ErrorCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) =>
      ErrorCardLayout(widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded);
}
