import 'package:aebeze/widgets/base_presenter.dart';

class AboutPresenter {
  final AboutPresenterView _view;

  AboutPresenter(this._view) {
    assert(_view != null);
  }
}

abstract class AboutPresenterView implements BasePresenterView {}
