import 'package:aebeze/widgets/base_presenter.dart';

class TermsPresenter {
  final TermsPresenterView _view;

  TermsPresenter(this._view) {
    assert(_view != null);
  }
}

abstract class TermsPresenterView implements BasePresenterView {}
