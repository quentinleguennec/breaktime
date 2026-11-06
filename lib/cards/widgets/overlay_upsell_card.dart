import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class OverlayUpsellCard extends StatefulWidget {
  final PageContext pageContext;

  OverlayUpsellCard(this.pageContext);

  @override
  _State createState() => _State();
}

class _State extends SafeState<OverlayUpsellCard> with SingleTickerProviderStateMixin {
  DataCard get card => widget.pageContext.card;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned(
          top: 545.0,
          left: 111.0,
          right: 111.0,
          child: Container(
              height: 44.0,
              child: RaisedButton(
                  child: Row(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Image.asset(Assets.iconGlobe, width: defaultPadding, height: defaultPadding)),
                    Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 16.0),
                        child: Text(
                          card.upsellData.text.toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ))
                  ]),
                  color: AppColors.brilliant,
                  onPressed: () => launch(card.upsellData.link),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(73.0))))),
      Padding(
          padding: EdgeInsets.only(left: defaultPadding, top: 386.0, right: 77.6, bottom: 253.0),
          child: Text(card.placement.header.toUpperCase(), style: AppTextStyles.subhead.copyWith(color: Colors.white))),
      Padding(
          padding: EdgeInsets.only(left: defaultPadding, top: 415.0, right: 53.0, bottom: 146.0),
          child: Text(card.placement.content,
              style: AppTextStyles.h2.copyWith(color: Colors.white, height: 1.2, fontSize: 30.0))),
    ]);
  }
}
