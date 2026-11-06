import 'package:aebeze/authentication/authentication_presenter.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class ResetPasswordPresenter extends AuthenticationPresenter {
  final ResetPasswordPresenterView _view;
  UserService _userService;

  ResetPasswordPresenter(this._view) : super(_view) {
    _userService = Injector().userService;
    assert(_view != null);
  }

  void resetPassword(String email) {
    _view.startProgress();
    _userService.resetPassword(email).then((_) => onSuccess()).catchError((error) => onError(error));
  }

  @override
  void onSuccess() {
    super.onSuccess();
    _view
      ..stopProgress()
      ..showAlertDialog(null, "authentication_password_reset_dialog_text", "ok");
  }
}

abstract class ResetPasswordPresenterView implements BasePresenterView, AuthenticationPresenterView {}
