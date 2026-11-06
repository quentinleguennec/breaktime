import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/messaging_card_layout.dart';

class MessagingCard extends BasicCard {
  MessagingCard(pageContext) : super(pageContext);

  @override
  BasicCardState createState() => _State();
}

class _State extends BasicCardState {
  bool isEditingMessage = false;

  void onEditMessageChanged(bool isEditing) => setMountedState(() => isEditingMessage = isEditing);

  @override
  MessagingCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) => MessagingCardLayout(
        widget.pageContext,
        animator,
        super.onBackgroundVideoLoaded,
        super.onBackgroundImageLoaded,
        isEditingMessage,
        onEditMessageChanged,
      );
}
