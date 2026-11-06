import 'package:aebeze/cards/phq9_card/phq9_question_card.dart';
import 'package:aebeze/cards/phq9_card/phq9_result_card.dart';
import 'package:aebeze/cards/phq9_card/phq9_start_card.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class PHQ9Presenter {
  PHQ9PresenterView _view;
  List<DataCard> wrappedCards;

  PHQ9Presenter(this._view) {
    assert(_view != null);
    buildWrappedCards();
  }

  void buildWrappedCards() {
    wrappedCards = List<DataCard>();

    /// We put the second question card twice to be able to skip the first result card if needed ans still play the animation seamlessly.
    wrappedCards.add(PHQ9StartCard.card);
    wrappedCards.addAll(PHQ9QuestionCard.cards.sublist(0, 2));
    wrappedCards.add(PHQ9ResultCard.getCard("phq9resultCard1"));
    wrappedCards.addAll(PHQ9QuestionCard.cards.sublist(1, PHQ9QuestionCard.cards.length));
    wrappedCards.add(PHQ9ResultCard.getCard("phq9resultCard2"));
  }
}

abstract class PHQ9PresenterView implements BasePresenterView {}
