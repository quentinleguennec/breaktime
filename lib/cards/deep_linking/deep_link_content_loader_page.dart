import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/deep_linking/deep_link_content_loader_page_presenter.dart';
import 'package:aebeze/mood_selector/daybreak_mood_selector_loading_page.dart';
import 'package:aebeze/mood_selector/mood_selector_page_loading.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DeepLinkContentLoaderPage extends PopupRoute<Null> {
  final Uri link;

  DeepLinkContentLoaderPage(this.link) : super(settings: TrackingService.deepLinkPage);

  @override
  Color get barrierColor => AppColors.tealish;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => true;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _PageLayout(link);
}

class _PageLayout extends StatefulWidget {
  final Uri link;

  _PageLayout(this.link);

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements DeepLinkContentLoaderPagePresenterView {
  DeepLinkContentLoaderPagePresenter presenter;
  ValueNotifier<bool> onLoadingNotifier = ValueNotifier(false);

  _PageLayoutState() {
    presenter = DeepLinkContentLoaderPagePresenter(this);
  }

  @override
  void initState() {
    super.initState();
    handleLink(widget.link);
  }

  void handleLink(Uri link) {
    presenter.fetchCard(link.queryParameters["uid"]).then((DataCard card) {
      pushDeepLinkCard(card ?? errorCard);
    }).catchError((_) {
      pushDeepLinkCard(errorCard);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: App.isDayBreak
            ? DaybreakMoodSelectorLoading(onLoadingAnimationCompleted: () {}, onLoadingNotifier: onLoadingNotifier)
            : MoodSelectorLoading(onLoadingAnimationCompleted: () {}, onLoadingNotifier: onLoadingNotifier),
      );
}
