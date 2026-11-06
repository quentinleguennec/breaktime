import 'package:aebeze/app.dart';
import 'package:aebeze/authentication/authentication_presenter.dart';
import 'package:aebeze/notifications/notification_manager_page.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/user_account/about_page.dart';
import 'package:aebeze/user_account/emergency_contacts_page.dart';
import 'package:aebeze/user_account/privacy_policy_page.dart';
import 'package:aebeze/user_account/terms_page.dart';
import 'package:aebeze/widgets/base_presenter.dart';

class UserAccountPresenter extends AuthenticationPresenter {
  final UserAccountPresenterView _view;
  UserService _userService;

  UserAccountPresenter(this._view) : super(_view) {
    _userService = Injector().userService;
    assert(_view != null);
  }

  void loadUser() => _userService.getUser().then(_view.updateUser).catchError((error) => onError(error));

  void logOut() => _userService.logout().then((_) => _view.pushAuthenticationPage());

  void showAboutPage() => _view.push(AboutPage());

  void showTermsPage() => App.isDayBreak ? _view.push(PrivacyPolicyPage()) : _view.push(TermsPage());

  void showEmergencyContactsPage() => _view.push(EmergencyContactsPage(isPrivacyPage: false));

  void showManageNotificationsPage() => _view.push(NotificationManagerPage());

  void showLoginPage() => _view.pushAuthenticationPage().then((_) => loadUser());

  void showEmailVerificationPage() => _view.pushEmailVerificationPage().then((_) => loadUser());
}

abstract class UserAccountPresenterView implements BasePresenterView, AuthenticationPresenterView {
  void updateUser(User user);
}
