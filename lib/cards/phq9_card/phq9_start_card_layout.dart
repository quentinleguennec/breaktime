import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/start_card/start_card_presenter.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class PHQ9StartCardLayout extends BasicCardLayout {
  static final String _cardContent = "cardContent";

  PHQ9StartCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(_cardContent, BoxConstraints.tightFor(width: size.width, height: size.height));
    positionChild(_cardContent, Offset.zero);
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addContent(list);
    return list;
  }

  void addContent(LayoutList list) => list.layout(_cardContent, () => _CardContent(pageContext));
}

class _CardContent extends StatefulWidget {
  final PageContext pageContext;

  _CardContent(this.pageContext);

  @override
  _CardContentState createState() => _CardContentState();
}

class _CardContentState extends BasePresenter<_CardContent>
    with TickerProviderStateMixin
    implements StartCardPresenterView {
  static const Duration revealCascadeDelay = const Duration(milliseconds: 125);

  AnimatedRevealTransitionController revealTransitionController;
  AnimationController fadeInButtonsAnimationController;

  Treatment get treatment => widget.pageContext.treatment;

  int get cascadingWidgetsCount => 3;

  @override
  void initState() {
    revealTransitionController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: cascadingWidgetsCount,
      baseDuration: const Duration(milliseconds: 300),
      delay: revealCascadeDelay,
    );

    fadeInButtonsAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    revealTransitionController.forward().then((_) => fadeInButtonsAnimationController?.forward());

    super.initState();
  }

  @override
  void dispose() {
    revealTransitionController?.dispose();
    fadeInButtonsAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 121.0,
              left: defaultPadding,
              right: defaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Title(
                    revealTransitionController: revealTransitionController,
                    scale: MediaQuery.of(context).size.width / defaultScreenWidth,
                  ),
                  ColumnSeparator.huge,
                  _Benefits(revealTransitionController: revealTransitionController),
                  _Description(revealTransitionController: revealTransitionController),
                ],
              ),
            ),
            _StartButton(
              animation: fadeInButtonsAnimationController,
              onPressed: widget.pageContext.onNextPressed,
            ),
          ],
        ),
      );
}

class _Title extends StatelessWidget {
  final double scale;
  final AnimatedRevealTransitionController revealTransitionController;

  _Title({
    @required this.scale,
    @required this.revealTransitionController,
  });

  @override
  Widget build(BuildContext context) => _CascadingWidget(
        animation: revealTransitionController.nextAnimation,
        child: TextScaled(
          localize(context, "phq9_start_card_title"),
          style: AppTextStyles.h1Huge,
          textScaleFactor: scale,
        ),
      );
}

class _Description extends StatelessWidget {
  final AnimatedRevealTransitionController revealTransitionController;

  _Description({@required this.revealTransitionController});

  @override
  Widget build(BuildContext context) => _CascadingWidget(
        animation: revealTransitionController.nextAnimation,
        child: TextScaled(
          localize(context, "phq9_start_card_description"),
          style: AppTextStyles.bodyReg,
        ),
      );
}

class _Benefits extends StatelessWidget {
  final AnimatedRevealTransitionController revealTransitionController;

  _Benefits({@required this.revealTransitionController});

  @override
  Widget build(BuildContext context) => _CascadingWidget(
        animation: revealTransitionController.nextAnimation,
        child: TextScaled(
          localize(context, "treatment_benefits").toUpperCase(),
          style: AppTextStyles.subheadSmall.copyWith(color: Colors.black.withOpacity(0.6)),
        ),
      );
}

class _StartButton extends StatelessWidget {
  final Animation animation;
  final VoidCallback onPressed;

  _StartButton({
    @required this.animation,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomRight,
        child: FadeTransition(
          opacity: animation,
          child: Container(
            padding: EdgeInsets.only(right: 16, bottom: 18 + MediaQuery.of(context).padding.bottom),
            child: ArrowIconButton(
              quarterTurns: 2,
              onPressed: onPressed,
              color: Colors.black,
            ),
          ),
        ),
      );
}

class _CascadingWidget extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  _CascadingWidget({
    @required this.child,
    @required this.animation,
  });

  @override
  Widget build(BuildContext context) => AnimatedRevealTransitionWidget(
        animation: animation,
        child: child,
        translationValue: 10.0,
      );
}
