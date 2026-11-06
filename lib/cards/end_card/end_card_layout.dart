import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/end_card/end_card_presenter.dart';
import 'package:aebeze/cards/start_card/start_end_card_shape_image.dart';
import 'package:aebeze/mood_selector/navigation_buttons.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/rating_buttons.dart';
import 'package:aebeze/widgets/reveal_container.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class EndCardLayout extends BasicCardLayout {
  static const String _cardContent = "cardContent";
  final Function onCommentInputChanged;
  final Function onRatingChanged;

  EndCardLayout(
    pageContext,
    animator,
    onVideoLoaded,
    onImageLoaded,
    this.onCommentInputChanged,
    this.onRatingChanged,
  ) : super(
          pageContext,
          animator,
          onVideoLoaded,
          onImageLoaded,
        );

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(_cardContent, BoxConstraints.expand(width: size.width, height: size.height));
    positionChild(_cardContent, Offset.zero);
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addContent(list);
    return list;
  }

  void addContent(LayoutList list) =>
      list.layout(_cardContent, () => _CardContent(pageContext, onCommentInputChanged, onRatingChanged));
}

class _CardContent extends StatefulWidget {
  final PageContext pageContext;
  final Function onCommentInputChanged;
  final Function onRatingChanged;

  _CardContent(this.pageContext, this.onCommentInputChanged, this.onRatingChanged);

  @override
  _CardContentState createState() => _CardContentState();
}

class _CardContentState extends BasePresenter<_CardContent>
    with TickerProviderStateMixin
    implements EndCardPresenterView {
  static const Duration revealCascadeDelay = const Duration(milliseconds: 125);
  static const int cascadingWidgetsCount = 5;
  static const double keyboardHeightMultiplier = 1.6;
  final ScrollController scrollController = ScrollController();

  EndCardPresenter presenter;
  int rating = 0;
  String treatmentComment;
  AnimatedRevealTransitionController revealTransitionController;
  AnimationController fadeInShapeAnimationController;

  PageContext get pageContext => widget.pageContext;

  Treatment get treatment => pageContext.treatment;

  double get innerHeight => MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical;

  double get keyboardHeight => MediaQuery.of(context).viewInsets.bottom;

  bool get isKeyboardShowing => keyboardHeight > 0;

  double get scrollViewHeight =>
      MediaQuery.of(context).size.height + MediaQuery.of(context).viewInsets.bottom / keyboardHeightMultiplier;

  _CardContentState() {
    presenter = EndCardPresenter(this);
  }

  @override
  void initState() {
    revealTransitionController = AnimatedRevealTransitionController(
      vsync: this,
      animationsCount: cascadingWidgetsCount,
      baseDuration: const Duration(milliseconds: 300),
      delay: revealCascadeDelay,
    );

    fadeInShapeAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);

    presenter.updateCompletedTreatments(treatment);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    super.initState();
  }

  @override
  void dispose() {
    revealTransitionController?.dispose();
    fadeInShapeAnimationController?.dispose();
    scrollController?.dispose();
    super.dispose();
  }

  void onVisibilityChanged() {
    if (pageContext.visibilityChangedNotifier.value == CardVisibilityChanged.onScreen) {
      if (revealTransitionController.isDismissed) {
        revealTransitionController?.forward();
        Future.delayed(revealCascadeDelay * 1, () {
          if (mounted) {
            fadeInShapeAnimationController?.forward();
          }
        });
      }
    }
  }

  void onDoneButtonPressed() {
    widget.pageContext.onNextPressed();
  }

  void onNumberButtonPressed(int number) {
    setMountedState(() => rating = number);
    widget.onRatingChanged(number);
  }

  Widget get titleAndHeader => _CascadingWidget(
        animation: revealTransitionController.nextAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextScaled(
              localize(context, "end_card_header").toUpperCase(),
              style: AppTextStyles.captionZirkonRegular.copyWith(color: AppColors.baseColorFaded),
            ),
            ColumnSeparator.tinyPlus,
            TextScaled(
              localize(context, "end_card_title"),
              style: AppTextStyles.startCardTitle,
              textScaleFactor: 1,
            ),
          ],
        ),
      );

  Widget get ratingTitle => _CascadingWidget(
        animation: revealTransitionController.nextAnimation,
        child: TextScaled(
          localize(context, "end_card_rating_header"),
          style: AppTextStyles.h5ZirkonRegular,
          textScaleFactor: 1,
        ),
      );

  Widget get ratingButtons => _CascadingWidget(
        animation: revealTransitionController.nextAnimation,
        child: RatingButtons(
          onNumberTapped: onNumberButtonPressed,
          rating: rating,
        ),
      );

  Widget get inputTextField => _CascadingWidget(
        animation: revealTransitionController.nextAnimation,
        child: TextField(
          style: AppTextStyles.inputField,
          textInputAction: TextInputAction.done,
          minLines: 3,
          maxLines: 5,
          onChanged: widget.onCommentInputChanged,
          onTap: () {
            /// The widget doesn't move all the way up by itself (as it normally should) when the keyboard is shown,
            /// here we wait a bit then manually animate it to scroll to the bottom.
            Future.delayed(const Duration(milliseconds: 110), () {
              if (mounted)
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
            });
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(smallPadding),
            border: InputBorder.none,
            filled: true,
            fillColor: AppColors.transparentBoxBackgroundColor,
            labelText: localize(context, "end_card_comment_label"),
            labelStyle: AppTextStyles.inputField.copyWith(color: AppColors.baseColorVeryFaded),
            alignLabelWithHint: true,
          ),
        ),
      );

  Widget get daybreakBackground => Image.asset(
        Assets.backgroundDefaultDaybreak,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fill,
      );

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          if (App.isDayBreak) daybreakBackground,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: rating == 0 ?? isKeyboardShowing
                ? 0
                : BottomNavigationButton.baseHeight + MediaQuery.of(context).padding.bottom,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.transparent,
              body: Stack(
                children: <Widget>[
                  StartEndCardShapeImage(
                    treatment: treatment,
                    animation: fadeInShapeAnimationController,
                  ),
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: bigPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(padding: const EdgeInsets.only(top: 250)),
                                titleAndHeader,
                                ColumnSeparator.veryBig,
                                _CascadingWidget(
                                  animation: revealTransitionController.nextAnimation,
                                  child: SeparatorLine.baseVeryFaded(),
                                ),
                                ColumnSeparator.big,
                                ratingTitle,
                                ColumnSeparator.big,
                                ratingButtons,
                                ColumnSeparator.veryBig,
                                inputTextField,
                                ColumnSeparator.big,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: rating == 0 ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RevealContainer(
                fadeInShapeAnimationController,
                child: BottomNavigationButton(
                  text: localize(context, "end_card_bottom_button").toUpperCase(),
                  onTap: widget.pageContext.onNextPressed,
                ),
              ),
            ),
          ),
        ],
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
