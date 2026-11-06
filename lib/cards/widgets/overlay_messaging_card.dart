import 'dart:async';
import 'dart:math';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/share_menu/share_menu_page/share_menu_page.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/slide_gesture_detector.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:aebeze/widgets/void_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class OverlayMessagingCard extends StatefulWidget {
  final PageContext pageContext;
  final ValueChanged<bool> onEditMessageChanged;

  OverlayMessagingCard(this.pageContext, this.onEditMessageChanged);

  @override
  _State createState() => _State();
}

class _State extends SafeState<OverlayMessagingCard> with SingleTickerProviderStateMixin {
  /// Used to scale up/down the boxes depending on the actual screen size.
  static const double _baseScreenWidth = 400.0;
  static const double _fadeInAnimationDuration = 350.0; // In ms.
  static const double _delayBetweenFadeIn = 100.0; // In ms.

  final textEditingController = TextEditingController();
  final FocusNode textEditingFocusNode = FocusNode();
  String selectedMessageBackgroundColor;
  int selectedBoxIndex;
  VoidNotifier selectedBoxReverseAnimationNotifier;
  ValueNotifier<bool> isEditMessageScreenHiddenNotifier = ValueNotifier<bool>(true);
  List<_MessageBox> _messageBoxWidgets;
  AnimationController cascadeBoxesAnimationController;

  ValueNotifier<CardVisibilityChanged> get visibilityChangedNotifier => widget.pageContext.visibilityChangedNotifier;

  DataCard get card => widget.pageContext.card;

  double get scale => MediaQuery.of(context).size.width / _baseScreenWidth;

  double get instructionTextPositionFromTop =>
      BasicCardLayout.timerPositionFromTop + MediaQuery.of(context).padding.top + 48.0;

  double get firstMessagePositionFromTop => instructionTextPositionFromTop + 50.0;

  double get textHorizontalPaddingAfterInflation => defaultPadding;

  double get editableTextPositionFromTop => instructionTextPositionFromTop + 26.0;

  List<_MessageBox> get messageBoxWidgets {
    _messageBoxWidgets ??= buildMessageBoxesList();
    return _messageBoxWidgets;
  }

  @override
  void initState() {
    super.initState();
    cascadeBoxesAnimationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: _fadeInAnimationDuration.round() * (card.messages.length - 1) + _delayBetweenFadeIn.round(),
      ),
    );

    widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);
  }

  @override
  void dispose() {
    widget.pageContext.visibilityChangedNotifier.removeListener(onVisibilityChanged);
    textEditingController?.dispose();
    cascadeBoxesAnimationController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.visibilityChangedNotifier.removeListener(onVisibilityChanged);
    widget.pageContext.visibilityChangedNotifier.addListener(onVisibilityChanged);
  }

  void onVisibilityChanged() {
    if (widget.pageContext.visibilityChangedNotifier.value == CardVisibilityChanged.onScreen) {
      cascadeBoxesAnimationController.forward();
    } else {
      closeEditMessageScreen();
    }
  }

  void onEditScreenShowing() {
    widget.onEditMessageChanged(true);
    widget.pageContext.cardTimerController.pause();
  }

  void onEditScreenDismissing() {
    widget.onEditMessageChanged(false);
    widget.pageContext.cardTimerController.resume();
  }

  void closeEditMessageScreen() {
    textEditingFocusNode.unfocus();
    if (!isEditMessageScreenHiddenNotifier.value) {
      isEditMessageScreenHiddenNotifier.value = true;
      onEditScreenDismissing();
      selectedBoxReverseAnimationNotifier.notifyListeners();

      /// Delay the refresh to have the box go under the others only at the end of the animation.
      Future.delayed(_MessageBox.animationDuration, () => setMountedState(() => selectedBoxIndex = null));
    }
  }

  List<_MessageBox> buildMessageBoxesList() {
    List<_MessageBox> widgets = List<_MessageBox>();
    int boxIndex = 0;
    int lastBoxIndex = card.messages.length - 1;
    double positionFromTop = firstMessagePositionFromTop;
    card.messages.forEach((Message m) {
      positionFromTop += m.verticalTranslation;
      _MessageBox box = buildMessageBox(
        message: m.message,
        boxIndex: boxIndex,
        positionFromTop: positionFromTop,
        rotation: m.rotation * pi / 180.0,
        horizontalTranslation: m.horizontalTranslation,
        backgroundColor: m.backgroundColor,
        textColor: m.textColor,
        fallAnimation: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: cascadeBoxesAnimationController,
            curve: Interval(
              (_delayBetweenFadeIn * (lastBoxIndex - boxIndex)) /
                  cascadeBoxesAnimationController.duration.inMilliseconds,
              (_delayBetweenFadeIn * (lastBoxIndex - boxIndex) + _fadeInAnimationDuration) /
                  cascadeBoxesAnimationController.duration.inMilliseconds,
              curve: Curves.linear,
            ),
          ),
        ),
      );
      widgets.add(box);
      positionFromTop += _MessageBox.boxHeight;
      boxIndex++;
    });
    return widgets;
  }

  Widget buildSelectMessageScreen() {
    List<Widget> stackChildren = List<Widget>();
    stackChildren.add(
      Positioned(
        top: instructionTextPositionFromTop,
        width: MediaQuery.of(context).size.width,
        child: TextScaled(
          localize(context, 'messaging_card_instructions').toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTextStyles.instruction,
        ),
      ),
    );

    /// Make sure the selected message is on top of all the others.
    if (selectedBoxIndex == null || selectedBoxIndex == messageBoxWidgets.length - 1) {
      stackChildren.addAll(messageBoxWidgets);
    } else {
      List<_MessageBox> orderedList = List<_MessageBox>();
      for (int i = 0; i < messageBoxWidgets.length; i++) {
        if (i != selectedBoxIndex) {
          orderedList.add(messageBoxWidgets[i]);
        }
      }
      orderedList.add(messageBoxWidgets[selectedBoxIndex]);
      stackChildren.addAll(orderedList);
    }
    return Stack(alignment: Alignment.topCenter, children: stackChildren);
  }

  _MessageBox buildMessageBox({
    @required String message,
    @required int boxIndex,
    @required double positionFromTop,
    @required double rotation,
    @required double horizontalTranslation,
    @required String backgroundColor,
    @required String textColor,
    @required Animation<double> fallAnimation,
  }) {
    VoidNotifier playReverseAnimationNotifier = VoidNotifier();
    return _MessageBox(
      /// A key is needed here because we re-order the parent stack during refreshState in [onPressed].
      key: UniqueKey(),
      text: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      rotation: rotation,
      scale: scale,
      horizontalTranslation: horizontalTranslation,
      positionFromTop: positionFromTop,
      paddingLeftAfterInflation: textHorizontalPaddingAfterInflation,
      paddingTopAfterInflation: editableTextPositionFromTop,
      playReverseAnimationNotifier: playReverseAnimationNotifier,
      fallAnimation: fallAnimation,
      onPressed: () {
        textEditingController.text = message;
        selectedMessageBackgroundColor = backgroundColor;
        selectedBoxIndex = boxIndex;
        selectedBoxReverseAnimationNotifier = playReverseAnimationNotifier;
        onEditScreenShowing();
        refreshState();
      },
      onInflated: () {
        isEditMessageScreenHiddenNotifier.value = false;
        selectedBoxReverseAnimationNotifier.notifyListeners();
      },
    );
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          buildSelectMessageScreen(),
          _EditMessageScreen(
            textPositionFromTop: editableTextPositionFromTop,
            textHorizontalPadding: textHorizontalPaddingAfterInflation,
            backgroundColorGetter: () => selectedMessageBackgroundColor,
            textEditingController: textEditingController,
            focusNode: textEditingFocusNode,
            onSubmitted: (String message) {
              Navigator.of(context)
                  .push(SharePage(isCardUrl: false, message: message, backgroundColor: AppColors.popupBackgroundColor))
                  .then((_) => Future.delayed(SharePage.customTransitionDuration, closeEditMessageScreen));
            },
            onDismissed: closeEditMessageScreen,
            isHiddenNotifier: isEditMessageScreenHiddenNotifier,
          ),
        ],
      );
}

class _EditMessageScreen extends StatefulWidget {
  final double textPositionFromTop;
  final double textHorizontalPadding;
  final ValueGetter<String> backgroundColorGetter;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onDismissed;
  final ValueNotifier<bool> isHiddenNotifier;

  _EditMessageScreen({
    @required this.textPositionFromTop,
    @required this.textHorizontalPadding,
    @required this.backgroundColorGetter,
    @required this.textEditingController,
    @required this.focusNode,
    @required this.onSubmitted,
    @required this.onDismissed,
    @required this.isHiddenNotifier,
  });

  @override
  _EditMessageScreenState createState() => _EditMessageScreenState();
}

class _EditMessageScreenState extends SafeState<_EditMessageScreen> {
  bool get isHidden => widget.isHiddenNotifier.value;

  @override
  void initState() {
    super.initState();
    widget.isHiddenNotifier.addListener(refreshState);
  }

  @override
  void dispose() {
    widget.isHiddenNotifier?.removeListener(refreshState);
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.isHiddenNotifier?.removeListener(refreshState);
    widget.isHiddenNotifier?.addListener(refreshState);
  }

  @override
  Widget build(BuildContext context) => isHidden
      ? Container()
      : WillPopScope(
          onWillPop: () async {
            widget.onDismissed();
            return false;
          },
          child: Stack(
            children: <Widget>[
              GestureDetector(
                /// To prevents the [PageView] to scroll.
                onHorizontalDragStart: (_) {},
                child: SwipeGestureDetector(
                  onSwipeValidated: (SwipeDirection direction) =>
                      direction == SwipeDirection.topToBottom ? widget.onDismissed() : null,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    padding: EdgeInsets.only(
                      top: widget.textPositionFromTop,
                      bottom: 100.0 + MediaQuery.of(context).padding.bottom,
                      left: widget.textHorizontalPadding,
                      right: widget.textHorizontalPadding,
                    ),
                    color: stringToColor(widget.backgroundColorGetter()),
                    child: TextField(
                      controller: widget.textEditingController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0.0),
                      ),
                      style: AppTextStyles.h4.copyWith(color: bestFontColor(widget.backgroundColorGetter())),
                      autofocus: true,
                      maxLines: null,
                      focusNode: widget.focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (String message) => widget.onSubmitted(message),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.5 * MediaQuery.of(context).padding.top + BasicCardLayout.timerPositionFromTop + 10,
                right: defaultPadding - 6.0,
                child: CloseIconButton(
                  containerWidth: 48.0,
                  containerHeight: 48.0,
                  size: 24.0,
                  onPressed: widget.onDismissed,
                ),
              ),
            ],
          ),
        );
}

class _MessageBox extends StatefulWidget {
  static const double boxWidth = 300.0;
  static const double boxHeight = 65.0;
  static const Duration animationDuration = const Duration(milliseconds: 200);

  final String text;
  final String backgroundColor;
  final String textColor;
  final double rotation;
  final double scale;
  final double horizontalTranslation;
  final double positionFromTop;
  final double paddingLeftAfterInflation;
  final double paddingTopAfterInflation;
  final VoidCallback onPressed;
  final VoidCallback onInflated;
  final ValueChanged<Size> textSizeCallback;
  final VoidNotifier playReverseAnimationNotifier;
  final Animation<double> fallAnimation;

  _MessageBox({
    key,
    this.text = "",
    this.backgroundColor,
    this.textColor,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.horizontalTranslation = 0.0,
    this.positionFromTop = 0.0,
    this.paddingLeftAfterInflation,
    this.paddingTopAfterInflation,
    this.onPressed,
    this.onInflated,
    this.textSizeCallback,
    this.playReverseAnimationNotifier,
    this.fallAnimation,
  }) : super(key: key);

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends SafeState<_MessageBox> with SingleTickerProviderStateMixin {
  AnimationController inflateAnimationController;
  Animation<double> inflateAnimation;
  Size textSize = Size.zero;

  /// [positionFromTop] needs to take [widget.scale] into account because it's out of [Transform.scale].
  double get positionFromTop => widget.positionFromTop * (1.0 - inflateAnimation.value) * widget.scale;

  double get rotation => widget.rotation * (1.0 - inflateAnimation.value);

  double get opacity => widget.fallAnimation.value;

  double get scale => widget.scale + (1.0 - widget.scale) * inflateAnimation.value;

  double get horizontalTranslation => widget.horizontalTranslation * (1.0 - inflateAnimation.value);

  double get width =>
      _MessageBox.boxWidth + (MediaQuery.of(context).size.width - _MessageBox.boxWidth) * inflateAnimation.value;

  double get height =>
      _MessageBox.boxHeight + (MediaQuery.of(context).size.height - _MessageBox.boxHeight) * inflateAnimation.value;

  Offset get textPosition => Offset(
        ((_MessageBox.boxWidth - textSize.width) / 2.0) * (1.0 - inflateAnimation.value) +
            widget.paddingLeftAfterInflation * inflateAnimation.value,
        ((_MessageBox.boxHeight - textSize.height) / 2.0) * (1.0 - inflateAnimation.value) +
            widget.paddingTopAfterInflation * inflateAnimation.value,
      );

  @override
  void initState() {
    super.initState();
    inflateAnimationController = AnimationController(vsync: this, duration: _MessageBox.animationDuration)
      ..addListener(refreshState);
    inflateAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: inflateAnimationController, curve: Curves.linear));

    widget.fallAnimation.addListener(refreshState);

    widget.playReverseAnimationNotifier.addListener(playReverseAnimation);
  }

  @override
  void dispose() {
    inflateAnimationController?.dispose();
    widget.playReverseAnimationNotifier?.removeListener(playReverseAnimation);
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.playReverseAnimationNotifier.removeListener(playReverseAnimation);
    widget.playReverseAnimationNotifier.addListener(playReverseAnimation);
  }

  void playReverseAnimation() => inflateAnimationController.reverse(from: 1.0);

  void onPressed() {
    if (widget.onPressed != null) widget.onPressed();
    HapticFeedback.mediumImpact();
    inflateAnimationController.forward().then((_) => widget.onInflated());
  }

  @override
  Widget build(BuildContext context) => Positioned(
        top: positionFromTop,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: onPressed,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(rotation)
                ..scale(scale)
                ..translate(horizontalTranslation, 0.0, 0.0),
              child: Container(
                width: width,
                height: height,
                color: stringToColor(widget.backgroundColor),
                child: _MessageText(
                  text: widget.text,
                  color: stringToColor(widget.textColor) ?? bestFontColor(widget.backgroundColor),
                  position: textSize.width == 0.0 ? null : textPosition,
                  textSizeCallback: (size) => textSize = size,
                ),
              ),
            ),
          ),
        ),
      );
}

/// Needed to get the size of the [Text] widget and animate it to the right position.
class _MessageText extends MultiChildLayout {
  static const String textWidget = "textWidget";
  static const double horizontalPadding = 40.0;
  final String text;
  final Color color;
  final Offset position;
  final ValueChanged<Size> textSizeCallback;

  _MessageText({this.text, this.color, this.position, this.textSizeCallback});

  @override
  LayoutList children(BuildContext context) => LayoutList()
    ..layout(
      textWidget,
      () => TextScaled(
        text,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.h4.copyWith(color: color),
      ),
    );

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    final Size textSize =
        layoutChild(textWidget, BoxConstraints.loose(Size(size.width - horizontalPadding, size.height)));
    textSizeCallback(textSize);
    final Offset centeredTextOffset =
        Offset((_MessageBox.boxWidth - textSize.width) / 2.0, (_MessageBox.boxHeight - textSize.height) / 2.0);
    positionChild(textWidget, position ?? centeredTextOffset);
  }
}
