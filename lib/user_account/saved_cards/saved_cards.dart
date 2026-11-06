import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/user_account/saved_cards/saved_cards_presenter.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/reveal_network_image.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SavedCards extends StatefulWidget {
  final ValueSetter<DataCard> onCardSelected;

  SavedCards({@required this.onCardSelected});

  @override
  _SavedCardsState createState() => _SavedCardsState();
}

class _SavedCardsState extends BasePresenter<SavedCards>
    with SingleTickerProviderStateMixin
    implements SavedCardsPresenterView {
  SavedCardsPresenter presenter;
  List<DataCard> savedCards;
  AnimationController controller;
  Animation fadeInAnimation;

  _SavedCardsState() {
    presenter = SavedCardsPresenter(this);
  }

  @override
  void initState() {
    super.initState(); // Keep that here as it changes the value of [inProgress].
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn))
      ..addListener(refreshState);
    inProgress = true;
    presenter.loadSavedCards();
  }

  @override
  dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void onSavedCardsLoaded(List<DataCard> savedCards) {
    inProgress = false;
    this.savedCards = savedCards;
    controller?.forward();
  }

  @override
  Widget build(BuildContext context) => Visibility(
        visible: savedCards != null && savedCards.length > 0,
        child: Opacity(
          opacity: fadeInAnimation.value,
          child: Column(
            children: [
              ColumnSeparator.medium,
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: TextScaled(
                        localize(context, "dashboard_your_saved_cards"),
                        style: AppTextStyles.subCategory,
                      ),
                    ),
                  )
                ],
              ),
              ColumnSeparator.tiny,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: const SeparatorLine(),
              ),
              ColumnSeparator.medium,
              Container(
                height: 210.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: savedCards?.length ?? 0,
                  padding: const EdgeInsets.only(
                      left: defaultPadding, right: defaultPadding - _SavedCardListItem.cardRightMargin),
                  itemBuilder: (context, index) => _SavedCardListItem(savedCards[index], widget.onCardSelected),
                ),
              ),
            ],
          ),
        ),
      );
}

class _SavedCardListItem extends StatelessWidget {
  static const double cardWidth = 144;
  static const double cardRightMargin = 16;
  final DataCard card;
  final ValueSetter<DataCard> onCardSelected;

  _SavedCardListItem(this.card, this.onCardSelected);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onCardSelected(card),
        child: Container(
          width: cardWidth,
          height: 210,
          margin: const EdgeInsets.only(right: cardRightMargin),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: cardWidth,
                height: 140.0,
                decoration: BoxDecoration(
                  color: backgroundColor(card.background),
                ),
                child: card.background.hasImage
                    ? new ClipRRect(
                        child: RevealNetworkImage(
                          imageUrl: card.background.image,
                          backgroundColor: backgroundColor(card.background),
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                child: TextScaled(
                  card.title ?? card.description ?? "",
                  style: AppTextStyles.captionZirkonBookSmall.copyWith(color: Colors.white.withOpacity(0.8)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              )
            ],
          ),
        ),
      );
}
