import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/share_menu/share_menu_page/share_menu_page_presenter.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/blur_filter.dart';
import 'package:aebeze/widgets/buttons/menu_button.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/slide_gesture_detector.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:share/share.dart';

class SharePage extends PopupRoute<Null> {
  static const double blurStrength = defaultPadding;
  static const Duration customTransitionDuration = const Duration(milliseconds: 300);

  final bool isCardUrl;
  final String cardUid;
  final String message;
  final Color backgroundColor;

  SharePage({
    @required this.isCardUrl,
    this.cardUid,
    this.message,
    this.backgroundColor,
  }) : super(settings: TrackingService.sharePage) {
    assert(!isCardUrl || cardUid != null, "cardUid can't be null if isCardUrl is true.");
  }

  @override
  Color get barrierColor => backgroundColor;

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => false;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => customTransitionDuration;

  @override
  Widget buildTransitions(
          BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      BlurFilter(
        blurStrength: blurStrength,
        animation: animation,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColors.popupBackgroundColor.withOpacity(animation.value * 0.6),
          child: child,
        ),
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _PageLayout(cardUid, message, animation, isCardUrl);
}

class _PageLayout extends StatefulWidget {
  final bool isCardUrl;
  final String cardUid;
  final String message;
  final Animation<double> animation;

  _PageLayout(this.cardUid, this.message, this.animation, this.isCardUrl);

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout> implements ShareMenuPagePresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> sharingApps = List();
  ShareMenuPagePresenter presenter;

  _PageLayoutState() {
    presenter = ShareMenuPagePresenter(this);
  }

  @override
  void initState() {
    presenter.getAvailableSharingApps().then((apps) => setMountedState(() => sharingApps = apps));
    widget.animation.addListener(() => refreshState());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showCopyTextSnackBar() => showSnackBarMessage(localize(
      context, widget.isCardUrl ? "share_menu_copy_link_snackbar_message" : "share_menu_copy_text_snackbar_message"));

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: widget.animation.value,
            child: Column(
              children: <Widget>[
                NavigationAppBarOverlay(
                  onPressed: pop,
                  withInvertedColor: true,
                ),
                Expanded(
                  child: _ShareMenu(
                    message: widget.message,
                    cardUid: widget.cardUid,
                    isCardUrl: widget.isCardUrl,
                    sharingApps: sharingApps,
                    onCopyLinkButtonPressed: showCopyTextSnackBar,
                    onShare: (type) => presenter.onShare(type, widget.cardUid),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ShareMenu extends StatelessWidget {
  final VoidCallback onCopyLinkButtonPressed;
  final ValueSetter<String> onShare;
  final String message;
  final String cardUid;
  final bool isCardUrl;
  final List<String> sharingApps;

  _ShareMenu({
    @required this.message,
    @required this.cardUid,
    @required this.isCardUrl,
    this.sharingApps,
    this.onCopyLinkButtonPressed,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    double gutter = 4.0 * MediaQuery.of(context).devicePixelRatio;
    double paddingTop = gutter / 2 + MediaQuery.of(context).padding.top;
    double paddingBottom = gutter + MediaQuery.of(context).padding.bottom;

    return SwipeGestureDetector(
      onSwipeValidated: (SwipeDirection direction) {
        if (direction == SwipeDirection.topToBottom) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: gutter, right: gutter),
                margin: EdgeInsets.all(16.0),
                alignment: Alignment.centerLeft,
                child: TextScaled(
                  isCardUrl
                      ? localize(context, "share_menu_title_for_url").toUpperCase()
                      : localize(context, "share_menu_title_for_message").toUpperCase(),
                  maxLines: 2,
                  style: AppTextStyles.subhead.copyWith(color: Colors.white, height: 1.2),
                ),
              ),
              Expanded(
                child: _ShareButtonsScrollview(
                  message: message,
                  cardUid: cardUid,
                  isCardUrl: isCardUrl,
                  sharingApps: sharingApps,
                  onCopyLinkButtonPressed: onCopyLinkButtonPressed,
                  onShare: onShare,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareButtonsScrollview extends StatelessWidget {
  final String message;
  final String cardUid;
  final bool isCardUrl;
  final List<String> sharingApps;
  final VoidCallback onCopyLinkButtonPressed;
  final ValueSetter<String> onShare;

  _ShareButtonsScrollview({
    @required this.message,
    @required this.cardUid,
    @required this.isCardUrl,
    this.sharingApps,
    this.onCopyLinkButtonPressed,
    this.onShare,
  });

  String getNonFacebookMessage(BuildContext context) =>
      isCardUrl ? localize(context, "share_prefilled_text") + '\n$cardShareUrl$cardUid' : message;

  MenuButton getButton(
    String localizedText,
    String imageAssetPath,
    VoidCallback onTap,
  ) =>
      MenuButton(
        localizedText,
        onTap: onTap,
        borderColor: Colors.white,
        verticalPadding: 6.0,
        isShareButton: true,
        icon: Image.asset(
          imageAssetPath,
          width: 22.0,
          height: 22.0,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
        height: constraints.maxHeight,
        margin: EdgeInsets.symmetric(horizontal: 25.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              /// Facebook can only share links
              if (isCardUrl && sharingApps.contains("facebook"))
                getButton(
                  "share_menu_facebook",
                  Assets.iconFacebookCircle,
                  () {
                    onShare("facebook");
                    FacebookLogin.shareUrlOnFacebook('$cardShareUrl$cardUid');
                  },
                ),

              /// Messenger can only share links
              if (isCardUrl && sharingApps.contains("messenger"))
                getButton(
                  "share_menu_messenger",
                  Assets.iconMessenger,
                  () {
                    onShare("messenger");
                    FacebookLogin.shareUrlOnMessenger('$cardShareUrl$cardUid');
                  },
                ),

              if (sharingApps.contains(Share.whatsApp))
                getButton(
                  "share_menu_whatsapp",
                  Assets.iconWhatsApp,
                  () {
                    onShare("whatsapp");
                    Share.shareWithWhatsApp(text: getNonFacebookMessage(context));
                  },
                ),

              if (sharingApps.contains(Share.telegram))
                getButton(
                  "share_menu_telegram",
                  Assets.iconTelegram,
                  () {
                    onShare("telegram");
                    Share.shareWithTelegram(text: getNonFacebookMessage(context));
                  },
                ),

              if (sharingApps.contains(Share.twitter))
                getButton(
                  "share_menu_twitter",
                  Assets.iconTwitter,
                  () {
                    onShare("twitter");
                    Share.shareWithTwitter(text: getNonFacebookMessage(context));
                  },
                ),

              if (sharingApps.contains(Share.email))
                getButton(
                  "share_menu_email",
                  Assets.iconEmail,
                  () {
                    onShare("email");
                    Share.shareWithEmail(text: getNonFacebookMessage(context));
                  },
                ),

              getButton(
                isCardUrl ? "share_menu_copy_link" : "share_menu_copy_text",
                Assets.iconCopyLink,
                () {
                  onShare("clipboard");
                  Clipboard.setData(ClipboardData(text: getNonFacebookMessage(context)));
                  onCopyLinkButtonPressed();
                },
              ),

              getButton(
                "share_menu_more",
                Assets.iconMore,
                () => Share.openShareDialog(getNonFacebookMessage(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
