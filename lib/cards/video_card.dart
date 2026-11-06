import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/video_card_layout.dart';

class VideoCard extends BasicCard {
  VideoCard(PageContext pageContext) : super(pageContext);

  @override
  BasicCardState createState() => _VideoCardState();
}

class _VideoCardState extends BasicCardState {
  bool isActive = false;

  @override
  VideoCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) => VideoCardLayout(
      widget.pageContext, animator, _onActivated, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded);

  void _onActivated() {
    isActive = true;
    startCardIfReady();
  }

  @override
  void startCardIfReady() {
    if (isActive) {
      super.startCardIfReady();
    }
  }
}
