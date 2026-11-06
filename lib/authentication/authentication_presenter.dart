import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/authentication/reset_password_page.dart';
import 'package:aebeze/services/api.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/user_account/about_page.dart';
import 'package:aebeze/user_account/privacy_policy_page.dart';
import 'package:aebeze/user_account/terms_page.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class AuthenticationPresenter {
  final AuthenticationPresenterView _view;
  UserService _userService;

  AuthenticationPresenter(this._view) {
    _userService = Injector().userService;
    assert(_view != null);
  }

  void openResetPasswordPagePage() => _view.push(ResetPasswordPage());

  void openAboutPage() => _view.push(AboutPage());

  void openTermsPage() {
    App.isDayBreak ? _view.push(PrivacyPolicyPage()) : _view.push(TermsPage());
  }

  void resetUserCredentials(context) =>
      _userService.logout().then((_) => _view.showSnackBarMessage(localize(context, "error_permission_denied")));

  Future<bool> checkUserEmailVerified() async {
    User user = await _userService.getUser();
    return user.isVerified;
  }

  void onSuccess() => _view.stopProgress();

  void onError(dynamic e) {
    if (e is ApiException && e.isUserSignInCancel()) {
      _view.stopProgress();
      return;
    }
    _view
      ..stopProgress()
      ..showError(e);
  }
}

abstract class AuthenticationPresenterView implements BasePresenterView {}
