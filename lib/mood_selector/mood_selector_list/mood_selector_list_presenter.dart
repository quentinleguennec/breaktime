import 'package:aebeze/widgets/base_presenter.dart';

class MoodFeelingsSelectorListPresenter {
  final MoodSelectorListPresenterView _view;

  MoodFeelingsSelectorListPresenter(this._view) {
    assert(_view != null);
  }
}

abstract class MoodSelectorListPresenterView implements BasePresenterView {}
