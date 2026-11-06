import 'package:aebeze/widgets/base_presenter.dart';

class MoodSelectorPresenter {
  final MoodSelectorPresenterView _view;

  MoodSelectorPresenter(this._view) {
    assert(_view != null);
  }

  void close() => _view.pop();
}

abstract class MoodSelectorPresenterView implements BasePresenterView {}
