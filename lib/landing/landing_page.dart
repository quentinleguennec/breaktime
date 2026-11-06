import 'dart:async';

import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/deep_linking/deep_link_content_loader_page.dart';
import 'package:aebeze/dashboard/root_page.dart';
import 'package:aebeze/landing/landing_presenter.dart';
import 'package:aebeze/tester/tester_page.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uni_links/uni_links.dart';

import '../theme.dart';

class Landing extends StatefulWidget {
  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<Landing> with WidgetsBindingObserver implements LandingPresenterView {
  LandingPagePresenter presenter;
  StreamSubscription<Uri> deepLinkSubscription;
  bool didSetup = false;

  _PageLayoutState() {
    presenter = LandingPagePresenter(this);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    presenter.checkInternetConnectivity().then((_) {
      presenter.showDialogIfAppNeedsUpdate().then((needsUpdate) {
        if (!needsUpdate) {
          setupAndShowContent();
        }
      });
    });
  }

  @override
  void dispose() {
    deepLinkSubscription.cancel();
    WidgetsBinding?.instance?.removeObserver(this);
    assert(true, "ERROR: Landing should not be disposed, deep-linking will not work.");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (presenter.isCheckingConnectivity) {
        return;
      }
      presenter.checkInternetConnectivity().then((_) {
        presenter.showDialogIfAppNeedsUpdate().then((needsUpdate) {
          if (!needsUpdate) {
            setupAndShowContent();
          }
        });
      });
    }
  }

  void setupAndShowContent() {
    if (didSetup) {
      return;
    }
    didSetup = true;
    WidgetsBinding.instance.removeObserver(this);
    push(App.testerMode ? TesterRoute() : RootPage(preventTransitionAnimation: true));

    /// [setupDeepLinking] must be called after pushing route to prevent issues with routes being popped too soon.
    setupDeepLinking();
  }

  @override
  Widget build(BuildContext context) => Container(color: App.isDayBreak ? AppColors.daybreakSplash : Colors.white);

  void setupDeepLinking() {
    getInitialUri().then((Uri link) {
      if (link == null) {
        return;
      }
      onDeepLinkOpened(link);
    }).catchError(
      (e) {
        if (App.inDebugMode) print("Error: ${e.message}");
      },
      test: (e) => e is PlatformException || e is FormatException,
    );

    deepLinkSubscription = getUriLinksStream().listen((Uri link) {
      onDeepLinkOpened(link);
    }, onError: (e) {
      if (App.inDebugMode) print("Error: $e");
    });
  }

  void onDeepLinkOpened(Uri link) {
    if (!link.toString().startsWith(aebezeUrl)) {
      return;
    }
    if (!link.queryParameters.containsKey("uid")) {
      pushSavedCard(errorCard);
    } else {
      push(DeepLinkContentLoaderPage(link));
    }
  }
}
