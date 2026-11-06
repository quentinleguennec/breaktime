import 'package:aebeze/app.dart';
import 'package:aebeze/authentication/authentication_page.dart';
import 'package:aebeze/cards/on_boarding_card/on_boarding_page.dart';
import 'package:aebeze/dashboard/dashboard_page.dart';
import 'package:aebeze/dashboard/root_bloc.dart';
import 'package:aebeze/mood_selector/daybreak_mood_selector_loading_page.dart';
import 'package:aebeze/mood_selector/mood_selector_bundle/app_start_mood_selector_bundle.dart';
import 'package:aebeze/mood_selector/mood_selector_page_loading.dart';
import 'package:aebeze/services/injector.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:screen/screen.dart';

class RootPage extends MaterialPageRoute<Null> {
  final bool preventTransitionAnimation;

  @override
  Duration get transitionDuration =>
      preventTransitionAnimation ? const Duration(milliseconds: 1) : super.transitionDuration;

  RootPage({this.preventTransitionAnimation = false})
      : super(
          builder: (_) => _RootPage(),
          settings: TrackingService.rootPage,
        );
}

class _RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends BasePresenter<_RootPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  RootBloc _rootBloc;
  ValueNotifier<bool> onLoadingNotifier = ValueNotifier(true);
  RootState _rootState;

  @override
  void initState() {
    _rootBloc = RootBloc();
    _rootBloc.load();
    _rootBloc.notificationStateObservable.listen((notification) {
      if (_rootState == null || _rootState.showLoading == true) {
        //Dismissing local notification, we support only mood tracking as local notification
      } else if (notification.isMoodSelector) {
        pushMoodSelector();
      }
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _rootBloc.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rootBloc.refreshRandomNotifications();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: Injector().rootBlocScaffoldKey,
        body: StreamBuilder(
          stream: _rootBloc.rootStateObservable,
          builder: (context, snapshot) {
            _rootState = snapshot.data;
            if (_rootState?.showLoading != null) {
              onLoadingNotifier.value = _rootState?.showLoading;
              Screen.keepOn(_rootState?.showLoading);
            }
            return Stack(
              children: [
                Visibility(
                  visible: _rootState?.showDashboard == true,
                  child: DashboardPageWidget(),
                ),
                Visibility(
                  visible: _rootState?.showDashboard == true,
                  child: AppStartMoodSelectorBundle(),
                ),
                Visibility(
                  visible: _rootState?.showAuthentication == true ||
                      (_rootState?.skipEmailVerification == false &&
                          _rootState?.user?.isAnonymous == false &&
                          _rootState?.user?.isVerified == false),
                  child: AuthenticationWidget(
                    isForcedAuthentication: true,
                    pageType: _rootState?.showAuthentication == true
                        ? AuthenticationPageType.authentication
                        : AuthenticationPageType.emailVerification,
                    onComplete: () => _rootBloc.onAuthenticationComplete(_rootState),
                  ),
                ),
                Visibility(
                  visible: _rootState?.showOnboarding == true,
                  child: OnBoardingPage(onGetStartedButtonPressed: () => _rootBloc.onboardingEnd(_rootState)),
                ),
                App.isDayBreak
                    ? DaybreakMoodSelectorLoading(
                        onLoadingAnimationCompleted: () => _rootBloc.onLoadingAnimationCompleted(),
                        onLoadingNotifier: onLoadingNotifier,
                      )
                    : MoodSelectorLoading(
                        onLoadingAnimationCompleted: () => _rootBloc.onLoadingAnimationCompleted(),
                        onLoadingNotifier: onLoadingNotifier,
                      ),
              ],
            );
          },
        ),
      );
}
