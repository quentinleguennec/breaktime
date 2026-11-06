import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/on_boarding_card/on_boarding_video_card_layout.dart';
import 'package:aebeze/services/model.dart';

class OnBoardingVideoCard extends BasicCard {
  OnBoardingVideoCard(PageContext pageContext) : super(pageContext);

  static List<DataCard> cards = [
    DataCard(
        uid: "onboardingCard2",
        type: "onboarding_video",
        duration: Duration(seconds: 10),
        background: Background(video: Assets.gabaSplashVideo, color: "0xff000000"),
        activeIngredients: [
          ActiveIngredient(name: "Gaba")
        ],
        messages: [
          Message(message: "We know that nature videos can trigger the  release of Gaba."),
          Message(message: "This is the chemical responsible for feelings of calm, comfort,  and serenity.")
        ]),
    DataCard(
        uid: "onboardingCard3",
        type: "onboarding_video",
        duration: Duration(seconds: 10),
        background: Background(video: Assets.oxytocinSplashVideo, color: "0xff000000"),
        activeIngredients: [
          ActiveIngredient(name: "Oxytocin")
        ],
        messages: [
          Message(message: "Cute puppy videos can trigger the release of Oxytocin."),
          Message(
              message: "This is the chemical responsible for bonding and love, released when you caress a loved one.")
        ]),
  ];

  @override
  BasicCardState createState() => _State();
}

class _State extends BasicCardState {
  @override
  OnBoardingVideoCardLayout buildCardLayout(BasicCard widget, CardAnimator animator) {
    animator.reset();
    return OnBoardingVideoCardLayout(
        widget.pageContext, animator, super.onBackgroundVideoLoaded, super.onBackgroundImageLoaded);
  }
}
