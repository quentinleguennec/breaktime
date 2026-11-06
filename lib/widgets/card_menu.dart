import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/cards_page/card_overlay_menu_controller.dart';
import 'package:aebeze/cards/cards_page/card_overlay_menu_presenter.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/share_menu/card_share_menu/card_share_menu.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/blur_filter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardMenu extends StatefulWidget {
  final ValueGetter<PageContext> pageContextGetter;
  final GlobalKey<ScaffoldState> scaffoldKey;

  CardMenu({
    @required this.pageContextGetter,
    @required this.scaffoldKey,
  });

  @override
  _State createState() => _State();
}

class _State extends BasePresenter<CardMenu> with TickerProviderStateMixin implements CardOverlayMenuPresenterView {
  static const double blurStrength = 5.0;
  static const double backgroundOpacity = 0.3;

  CardOverlayMenuPresenter presenter;
  AnimationController hideUnhideAnimationController;

  // TODO: AnimatedRevealTransitionController is not currently used. Remove if it is not added back soon.
  AnimatedRevealTransitionController cascadingRevealAnimationController;

  PageContext get pageContext => widget.pageContextGetter();

  CardOverlayMenuController get controller => pageContext.menuController;

  bool get isHidden => controller.isHidden;

  DataCard get currentCard => pageContext.card;

  bool get hasActiveIngredientsMoreInfo =>
      presenter.getCardActiveIngredient(currentCard)?.supportingSciencesUids?.isNotEmpty == true;

  VoidCallback get onMoreInfoButtonPressedCallback =>
      () => presenter.openSupportingSciencesPage(currentCard.supportingSciencesUids);

  VoidCallback get onShareButtonPressedCallback =>
      currentCard.isStartCard() || currentCard.isErrorCard() ? null : () => presenter.openSharePage(currentCard);

  String get title => currentCard.title;

  String get description => currentCard.description;

  String get author => currentCard.creator;

  String get courtesy => currentCard.source;

  String get activeIngredient => isEmptyOrNull(currentCard.activeIngredients) ||
          currentCard.activeIngredients.first.name == "Experimental Medicine"
      ? null
      : currentCard.activeIngredients.first.name;

  String get supportingScienceTitle => isEmptyOrNull(currentCard.supportingSciencesUids)
      ? null
      : presenter.getSupportingScienceTitle(currentCard.supportingSciencesUids.first);

  /// The revealTransitionController needs to how the number of items to animates before hand. If you add/remove animated items don't forget to update this.
  int get animatedWidgetsCount {
    int count = 8;
    if (description == null) count--;
    if (author == null && courtesy == null) count--;
    if (supportingScienceTitle == null) count -= 2;
    if (activeIngredient == null) count--;
    return count;
  }

  _State() {
    presenter = CardOverlayMenuPresenter(this);
  }

  @override
  void initState() {
    controller.addListener(onMenuVisibilityChanged);

    hideUnhideAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(refreshState);

    cascadingRevealAnimationController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: animatedWidgetsCount,
      baseDuration: const Duration(milliseconds: 300),
    );
    cascadingRevealAnimationController.value = 1;

    if (presenter.getCardInstructionType(currentCard) == CardInstructionType.tap) {
      pageContext.cardTimerController?.pause();
    }

    super.initState();
  }

  @override
  void dispose() {
    controller?.removeListener(onMenuVisibilityChanged);
    hideUnhideAnimationController?.dispose();
    cascadingRevealAnimationController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContextGetter().menuController?.removeListener(onMenuVisibilityChanged);
    controller?.addListener(onMenuVisibilityChanged);
  }

  void onMenuVisibilityChanged() {
    if (isHidden) {
      hideUnhideAnimationController?.reverse();
    } else {
      cascadingRevealAnimationController?.animationsCount = animatedWidgetsCount;
      hideUnhideAnimationController?.forward();
    }
  }

  Widget get backgroundBlurred => BlurFilter(
        blurStrength: blurStrength,
        animation: hideUnhideAnimationController,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColors.popupBackgroundColor.withOpacity(hideUnhideAnimationController.value * backgroundOpacity),
        ),
      );

  Widget get menuContent => Opacity(
        opacity: hideUnhideAnimationController.value,
        child: _Content(
          cascadingAnimationController: cascadingRevealAnimationController,
          onMoreInfoButtonPressed: onMoreInfoButtonPressedCallback,
          onCrossButtonPressed: controller.hide,
          title: title,
          description: description,
          author: author,
          supportingScienceTitle: supportingScienceTitle,
          courtesy: courtesy,
          activeIngredient: activeIngredient,
          cardUid: currentCard.uid,
          scaffoldKey: widget.scaffoldKey,
        ),
      );

  @override
  Widget build(BuildContext context) => Visibility(
        visible: !hideUnhideAnimationController.isDismissed,
        child: Stack(children: [
          backgroundBlurred,
          menuContent,
        ]),
      );
}

class _Content extends StatelessWidget {
  final AnimatedRevealTransitionController cascadingAnimationController;
  final VoidCallback onMoreInfoButtonPressed;
  final VoidCallback onCrossButtonPressed;
  final String title;
  final String description;
  final String author;
  final String courtesy;
  final String supportingScienceTitle;
  final String activeIngredient;
  final String cardUid;
  final GlobalKey<ScaffoldState> scaffoldKey;

  _Content({
    @required this.cascadingAnimationController,
    @required this.onMoreInfoButtonPressed,
    @required this.onCrossButtonPressed,
    @required this.title,
    @required this.description,
    @required this.author,
    @required this.courtesy,
    @required this.supportingScienceTitle,
    @required this.activeIngredient,
    @required this.cardUid,
    @required this.scaffoldKey,
  });

  Widget buildColumnElement({@required Widget child}) => AnimatedRevealTransitionWidget(
        animation: cascadingAnimationController.nextAnimation,
        child: child,
        translationValue: -10.0,
      );

  Widget buildTextWithHeader({@required String header, String text, int maxLines}) => buildColumnElement(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextScaled(
              header ?? "",
              style: AppTextStyles.h7ZirkonRegular.copyWith(color: Colors.white.withOpacity(0.6)),
            ),
            ColumnSeparator.tinyPlus,
            TextScaled(
              text ?? "",
              style: AppTextStyles.h5ZirkonRegular.copyWith(color: AppColors.whiteFaded),
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
            ),
          ],
        ),
      );

  Widget buildTitle() => buildColumnElement(
        child: TextScaled(
          title ?? "",
          textScaleFactor: 1,
          style: AppTextStyles.h3SmallProtoGroteskLight.copyWith(color: Colors.white),
        ),
      );

  Widget buildInformation(BuildContext context) => buildTextWithHeader(
        header: localize(context, "card_menu_information"),
        text: description,
      );

  Widget buildCourtesy(BuildContext context) => buildTextWithHeader(
        header: localize(context, "card_menu_courtesy"),
        maxLines: 5,
        text: "${author ?? ""}${!isEmptyOrNull(author) && !isEmptyOrNull(courtesy) ? "\n" : ""}${courtesy ?? ""}",
      );

  Widget buildReference(BuildContext context) => buildTextWithHeader(
        header: localize(context, "card_menu_reference"),
        text: supportingScienceTitle,
      );

  buildCardExplanationText(BuildContext context) => buildColumnElement(
        child: RichText(
          text: TextSpan(
            text: localize(context, "card_menu_explanation_text_start"),
            style: AppTextStyles.bodyLight.copyWith(color: Colors.white.withOpacity(0.6)),
            children: <TextSpan>[
              TextSpan(text: activeIngredient, style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: localize(context, "card_menu_explanation_text_end")),
            ],
          ),
        ),
      );

  Widget buildMoreInfoButton(BuildContext context) => buildColumnElement(
        child: GestureDetector(
          onTap: onMoreInfoButtonPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.transparent,
            alignment: Alignment.centerLeft,
            child: TextScaled(
              localize(context, 'card_menu_more_information').toUpperCase(),
              style: AppTextStyles.h5ZirkonRegular.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildColumnElement(
              child: NavigationAppBarOverlay(
                isStatusBarTextWhite: true,
                withInvertedColor: !App.isDayBreak,
                onPressed: onCrossButtonPressed,
              ),
            ),
            ColumnSeparator.veryBig,
            Padding(
              padding: EdgeInsets.only(
                left: bigPadding,
                right: bigPadding,
                bottom: bigPadding + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildTitle(),
                  ColumnSeparator.medium,
                  buildColumnElement(child: SeparatorLine()),
                  ColumnSeparator.big,
                  if (!App.isDayBreak) ...[
                    CardShareMenu(cardUid: cardUid, scaffoldKey: scaffoldKey),
                    ColumnSeparator.veryBig,
                  ],
                  if (description != null) ...[
                    buildInformation(context),
                    ColumnSeparator.veryBig,
                  ],
                  if (author != null || courtesy != null) ...[
                    buildCourtesy(context),
                    ColumnSeparator.veryBig,
                  ],
                  if (supportingScienceTitle != null) ...[
                    buildReference(context),
                    ColumnSeparator.big,
                    buildMoreInfoButton(context),
                    ColumnSeparator.big,
                  ],
                  if (activeIngredient != null) buildCardExplanationText(context),
                ],
              ),
            ),
          ],
        ),
      );
}
