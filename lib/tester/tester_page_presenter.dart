import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:collection/collection.dart';

class TesterPagePresenter {
  final TesterPagePresenterView _view;
  Api _api;

  TesterPagePresenter(this._view) {
    _api = Injector().api;
    assert(_view != null);
  }

  void loadData() async {
    _view.showCards(null);
    _api.fetchDraftCards().then((cards) => _view.showCards(cards)).catchError((e) => _view.showError(e));
    _api.fetchDraftTreatments().then((treatments) {
      Map<String, List<Treatment>> groupedTreatments = groupBy(treatments, (Treatment treatment) => treatment.type);
      groupedTreatments.forEach((_, list) => list.sort((t1, t2) => t1.day.compareTo(t2.day)));
      _view.showTreatments(groupedTreatments);
    }).catchError((e) => _view.showError(e));
  }

  void onDataCardSelected(DataCard card) => _view.pushSavedCard(card);

  void onTreatmentSelected(Treatment treatment) => _view.pushTreatment(treatment);
}

abstract class TesterPagePresenterView implements BasePresenterView {
  void showCards(List<DataCard> cards);

  void showTreatments(Map<String, List<Treatment>> treatments);
}
