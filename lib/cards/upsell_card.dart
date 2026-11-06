import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/upsell_card_layout.dart';

class UpsellCard extends BasicCard {
  UpsellCard(PageContext pageContext) : super(pageContext);

  @override
  BasicCardState createState() => _UpsellCardState();
}

class _UpsellCardState extends BasicCardState {
  @override
  UpsellCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) =>
      UpsellCardLayout(widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded);
}
