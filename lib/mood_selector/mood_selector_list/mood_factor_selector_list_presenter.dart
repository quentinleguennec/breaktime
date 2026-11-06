import 'package:aebeze/widgets/base_presenter.dart';

class MoodFactorSelectorListPresenter {
  final MoodFactorSelectorListPresenterView _view;

  MoodFactorSelectorListPresenter(this._view) {
    assert(_view != null);
  }
}

abstract class MoodFactorSelectorListPresenterView implements BasePresenterView {}
