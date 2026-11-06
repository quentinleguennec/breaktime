import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/on_boarding_card/on_boarding_animated_background_card_layout.dart';
import 'package:aebeze/services/model.dart';

class OnBoardingAnimatedBackgroundCard extends BasicCard {
  final bool isFirstCard;

  OnBoardingAnimatedBackgroundCard(PageContext pageContext, this.isFirstCard) : super(pageContext);

  static List<DataCard> cards = [
    DataCard(
      uid: "onboardingCard1",
      type: "onboarding_video",
      duration: Duration(seconds: 10),
      background: Background(video: Assets.justSnowing, color: "0xff000000"),
      messages: [
        Message(message: "Like the weather, we all experience changes in mood."),
        Message(message: "But each of us has the power to shape the way that we feel.")
      ],
    ),
    DataCard(
      uid: "onboardingCard4",
      type: "onboarding_animated",
      duration: Duration(seconds: 10),
      background: Background(color: "0xff000000"),
      messages: [
        Message(message: "This is what we do."),
        Message(message: "We use the chemicals already in your brain to help you feel better.")
      ],
    )
  ];

  @override
  BasicCardState createState() => _State(isFirstCard);
}

class _State extends BasicCardState {
  final bool isFirstCard;

  _State(this.isFirstCard);

  @override
  OnBoardingAnimatedBackgroundCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) =>
      OnBoardingAnimatedBackgroundCardLayout(
          widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded, isFirstCard);
}
