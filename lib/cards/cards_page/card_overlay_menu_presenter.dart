import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/memory_cache.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/share_menu/share_menu_page/share_menu_page.dart';
import 'package:aebeze/supporting_sciences/supporting_sciences_page.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/base_presenter.dart';

enum CardInstructionType { hold, tap }

class CardOverlayMenuPresenter {
  CardOverlayMenuPresenterView _view;
  MemoryCache _cache;

  CardOverlayMenuPresenter(this._view) {
    _cache = Injector().cache;
    assert(_view != null);
  }

  String getSupportingScienceTitle(String supportingSciencesUid) => _cache.supportingSciences
      ?.firstWhere(
        (supportingScience) => supportingScience.uid == supportingSciencesUid,
        orElse: () => null,
      )
      ?.title;

  void openSupportingSciencesPage(List<String> supportingSciencesUids) {
    List<SupportingScience> supportingSciences = supportingSciencesUids
        .map(
          (uid) => _cache.supportingSciences?.firstWhere(
            (supportingScience) => supportingScience.uid == uid,
            orElse: () => null,
          ),
        )
        .where((supportingScience) => supportingScience != null)
        .toList(growable: false);
    _view.push(
      SupportingSciencesPage(
        supportingSciences: supportingSciences,
      ),
    );
  }

  void openSharePage(DataCard card) {
    if (card.isStartCard() || card.isEndCard() || card.isErrorCard()) {
      return;
    }
    _view.push(SharePage(isCardUrl: true, cardUid: card.uid));
  }

  ActiveIngredient getCardActiveIngredient(DataCard card) => isEmptyOrNull(card.activeIngredients)
      ? null
      : _cache.activeIngredients
          ?.firstWhere((activeIngredient) => card.activeIngredients.first == activeIngredient, orElse: () => null);

  CardInstructionType getCardInstructionType(DataCard card) => card.isBasicCard() ||
          card.isDragCard() ||
          card.isMessagingCard() ||
          card.isWildcardCard() ||
          card.isUpsellCard() ||
          card.isStoryCard() ||
          card.isAudioCard() ||
          card.isErrorCard()
      ? CardInstructionType.tap
      : CardInstructionType.hold;
}

abstract class CardOverlayMenuPresenterView implements BasePresenterView {}
