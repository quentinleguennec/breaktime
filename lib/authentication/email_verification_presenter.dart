import 'package:aebeze/app.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/services/user_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class EmailVerificationPresenter {
  final EmailVerificationPresenterView _view;
  UserService _userService;
  TrackingService _trackingService;

  EmailVerificationPresenter(this._view) {
    assert(_view != null);
    _userService = Injector().userService;
    _trackingService = Injector().trackingService;
  }

  Future<void> logout() => _userService.logout();

  void sendVerificationEmail(BuildContext context) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    try {
      await user.sendEmailVerification();
      _view.showSnackBarMessage(localize(context, "verification_email_snackbar") + "\n${user.email}");
    } catch (e) {
      if (e is PlatformException && e.code == "ERROR_TOO_MANY_REQUESTS") {
        if (App.inDebugMode) print(e);
        if (user?.email != null) {
          _view.showSnackBarMessage(localize(context, "verification_email_snackbar") + "\n${user.email}");
        }
        return;
      } else {
        _view.showError(e);
      }
    }
  }

  Future<bool> recheckUserVerified() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await user.reload();
    if (user.isEmailVerified) {
      _trackingService.emailVerificationCompleted();
    }
    return user.isEmailVerified;
  }
}

abstract class EmailVerificationPresenterView implements BasePresenterView {}
