import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/wildcard_card_layout.dart';

class WildcardCard extends BasicCard {
  WildcardCard(PageContext pageContext) : super(pageContext);

  @override
  BasicCardState createState() => _WildcardCardState();
}

class _WildcardCardState extends BasicCardState {
  bool isOverlayDismissed = false;

  @override
  WildcardCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) => WildcardCardLayout(
        widget.pageContext,
        animator,
        onOverlayDismissed,
        isOverlayDismissed,
        super.onBackgroundVideoLoaded,
        super.onBackgroundImageLoaded,
      );

  void onOverlayDismissed() => setMountedState(() => isOverlayDismissed = true);
}
