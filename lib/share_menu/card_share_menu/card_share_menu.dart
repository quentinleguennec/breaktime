import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/share_menu/card_share_menu/card_share_menu_presenter.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:share/share.dart';

class CardShareMenu extends StatefulWidget {
  final String cardUid;
  final GlobalKey<ScaffoldState> scaffoldKey;

  CardShareMenu({
    @required this.cardUid,
    @required this.scaffoldKey,
  });

  @override
  _CardShareMenuState createState() => _CardShareMenuState();
}

class _CardShareMenuState extends BasePresenter<CardShareMenu> implements CardShareMenuPresenterView {
  static const double spaceBetweenButtons = 24;
  static const int numberOfButtonsPerRow = 4;

  List<String> sharingApps;
  CardShareMenuPresenter presenter;

  _CardShareMenuState() {
    presenter = CardShareMenuPresenter(this);
  }

  @override
  void initState() {
    presenter.getAvailableSharingApps().then((apps) => setMountedState(() => sharingApps = apps));
    super.initState();
  }

  String getNonFacebookMessage(BuildContext context) =>
      localize(context, "share_prefilled_text") + '\n$cardShareUrl${widget.cardUid}';

  void showCopyTextSnackBar() => widget.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: TextScaled(localize(context, "share_menu_copy_link_snackbar_message")),
        ),
      );

  @override
  Widget build(BuildContext context) => isEmptyOrNull(sharingApps)
      ? Container()
      : Wrap(
          spacing: spaceBetweenButtons,
          runSpacing: 20,
          children: [
            if (sharingApps.contains("facebook"))
              _ShareButton(
                text: localize(context, "share_menu_facebook"),
                image: Assets.iconShareFacebook,
                onPressed: () {
                  presenter.onShare("facebook", widget.cardUid);
                  FacebookLogin.shareUrlOnFacebook('$cardShareUrl${widget.cardUid}');
                },
              ),
            if (sharingApps.contains("messenger"))
              _ShareButton(
                text: localize(context, "share_menu_messenger"),
                image: Assets.iconMessenger,
                onPressed: () {
                  presenter.onShare("messenger", widget.cardUid);
                  FacebookLogin.shareUrlOnMessenger('$cardShareUrl${widget.cardUid}');
                },
              ),
            if (sharingApps.contains(Share.whatsApp))
              _ShareButton(
                text: localize(context, "share_menu_whatsapp"),
                image: Assets.iconShareWhatsapp,
                onPressed: () {
                  presenter.onShare("whatsapp", widget.cardUid);
                  Share.shareWithWhatsApp(text: getNonFacebookMessage(context));
                },
              ),
            if (sharingApps.contains(Share.telegram))
              _ShareButton(
                text: localize(context, "share_menu_telegram"),
                image: Assets.iconTelegram,
                onPressed: () {
                  presenter.onShare("telegram", widget.cardUid);
                  Share.shareWithTelegram(text: getNonFacebookMessage(context));
                },
              ),
            if (sharingApps.contains(Share.twitter))
              _ShareButton(
                text: localize(context, "share_menu_twitter"),
                image: Assets.iconShareTwitter,
                onPressed: () {
                  presenter.onShare("twitter", widget.cardUid);
                  Share.shareWithTwitter(text: getNonFacebookMessage(context));
                },
              ),
            if (sharingApps.contains(Share.email))
              _ShareButton(
                text: localize(context, "share_menu_email"),
                image: Assets.iconEmail,
                onPressed: () {
                  presenter.onShare("email", widget.cardUid);
                  Share.shareWithEmail(text: getNonFacebookMessage(context));
                },
              ),
            _ShareButton(
              text: localize(context, "share_menu_copy_link"),
              image: Assets.iconCopyLink,
              onPressed: () {
                presenter.onShare("clipboard", widget.cardUid);
                Clipboard.setData(ClipboardData(text: getNonFacebookMessage(context)));
                showCopyTextSnackBar();
              },
            ),
            _ShareButton(
              text: localize(context, "share_menu_more"),
              image: Assets.iconShareMore,
              onPressed: () => Share.openShareDialog(getNonFacebookMessage(context)),
            ),
          ],
        );
}

class _ShareButton extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback onPressed;

  _ShareButton({
    @required this.image,
    @required this.text,
    @required this.onPressed,
  });

  double getImageSize(BuildContext context) =>
      (MediaQuery.of(context).size.width -
          2 * bigPadding -
          _CardShareMenuState.spaceBetweenButtons * (_CardShareMenuState.numberOfButtonsPerRow - 1)) /
      _CardShareMenuState.numberOfButtonsPerRow;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              width: getImageSize(context),
              height: getImageSize(context),
              image: AssetImage(image),
            ),
            ColumnSeparator.tinyPlus,
            TextScaled(
              text,
              style: AppTextStyles.h7ZirkonRegular.copyWith(color: AppColors.whiteFaded),
            ),
          ],
        ),
      );
}
