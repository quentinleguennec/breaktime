import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/widgets/card_background_image.dart';
import 'package:aebeze/cards/widgets/card_background_video_player.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/reveal_container.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../widgets/column_separator.dart';

const Size _smallTextBoxSize = const Size(103.0, 56.0);
const Size _bigTextBoxSize = const Size(243.0, 283.0);
const double _boxPositionFromBottom = 86.0;
const BoxShadow _shadow = const BoxShadow(
  color: const Color(0x90000000),
  blurRadius: 7.0,
  offset: const Offset(3.0, 3.0),
);

class OverlayWildcardCard extends StatefulWidget {
  final PageContext pageContext;
  final VoidCallback onWilldcardOverlayDismissed;

  OverlayWildcardCard(this.pageContext, this.onWilldcardOverlayDismissed);

  @override
  _OverlayWildcardCardState createState() => _OverlayWildcardCardState();
}

class _OverlayWildcardCardState extends SafeState<OverlayWildcardCard> {
  bool isBigBox = false;
  bool isHidden = false;

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return Container();
    }

    List<Widget> stackChildren = List<Widget>();
    WildcardData wildcardData = widget.pageContext.card.wildcardData;

    Size screenSize = MediaQuery.of(context).size;
    if (wildcardData.hasBackgroundImage()) {
      stackChildren.add(Container(
          width: screenSize.width, height: screenSize.height, child: CardBackgroundImage(wildcardData.background)));
    }
    if (wildcardData.hasVideo()) {
      stackChildren.add(Container(
          width: screenSize.width, height: screenSize.height, child: CardBackgroundVideoPlayer(widget.pageContext)));
    }

    stackChildren.add(_TextBox(wildcardData, onBigBoxTapped));

    return Container(
      color: stringToColor(wildcardData.background.color),
      child: Stack(children: stackChildren),
    );
  }

  void onBigBoxTapped() {
    widget.onWilldcardOverlayDismissed();
    setMountedState(() => isHidden = true);
  }
}

class _TextBox extends StatefulWidget {
  final WildcardData wildcardData;
  final VoidCallback onTap;

  _TextBox(this.wildcardData, this.onTap);

  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends SafeState<_TextBox> {
  bool isBigBox = false;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          isBigBox
              ? _BigTextBox(
                  widget.wildcardData.headline, widget.wildcardData.text, widget.wildcardData.boxColor, widget.onTap)
              : _SmallTextBox(widget.wildcardData.boxColor, onSmallBoxExpanded),
        ],
      );

  void onSmallBoxExpanded() => setMountedState(() => isBigBox = true);
}

class _BigTextBox extends StatelessWidget {
  final String headline;
  final String text;
  final String backgroundColor;
  final VoidCallback onTap;

  _BigTextBox(this.headline, this.text, this.backgroundColor, this.onTap);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomLeft,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: Container(
            width: _bigTextBoxSize.width,
            height: _bigTextBoxSize.height,
            decoration: BoxDecoration(color: stringToColor(backgroundColor), boxShadow: [_shadow]),
            padding: const EdgeInsets.all(16.0),
            margin: EdgeInsets.only(bottom: _boxPositionFromBottom + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ColumnSeparator.medium,
                TextScaled(headline,
                    style: AppTextStyles.h4.copyWith(color: bestFontColor(backgroundColor)),
                    softWrap: false,
                    overflow: TextOverflow.fade),
                ColumnSeparator.big,
                TextScaled(
                  text,
                  style: AppTextStyles.h4.copyWith(color: bestFontColor(backgroundColor)),
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ),
      );
}

class _SmallTextBox extends StatefulWidget {
  final String backgroundColor;
  final VoidCallback onTap;

  _SmallTextBox(this.backgroundColor, this.onTap);

  @override
  _SmallTextBoxState createState() => _SmallTextBoxState();
}

class _SmallTextBoxState extends SafeState<_SmallTextBox> with TickerProviderStateMixin {
  AnimationController fadeController;
  AnimationController expandController;
  Animation<double> fadeAnimation;
  Animation<Size> expandAnimation;
  bool isExpanding = false;

  initState() {
    fadeController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    expandController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(fadeController);
    expandAnimation = Tween(begin: Size.zero, end: _bigTextBoxSize).animate(expandController)
      ..addListener(() => setMountedState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomLeft,
        child: GestureDetector(
          onTap: isExpanding
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  fadeController.forward().then((_) {
                    isExpanding = true;
                    expandAnimation = Tween(begin: _smallTextBoxSize, end: _bigTextBoxSize).animate(expandController)
                      ..addListener(() => setMountedState(() {}));
                    expandController.forward().then((_) {
                      isExpanding = false;
                      widget.onTap();
                    });
                  });
                },
          child: Container(
              width: isExpanding ? expandAnimation.value.width : _smallTextBoxSize.width,
              height: isExpanding ? expandAnimation.value.height : _smallTextBoxSize.height,
              decoration: BoxDecoration(color: stringToColor(widget.backgroundColor), boxShadow: [_shadow]),
              margin: EdgeInsets.only(bottom: _boxPositionFromBottom + MediaQuery.of(context).padding.bottom),
              child: RevealContainer(fadeAnimation,
                  child: TextScaled(localize(context, "wildcardSmallBox"),
                      style: AppTextStyles.instruction.copyWith(color: bestFontColor(widget.backgroundColor)))),
              alignment: Alignment.center),
        ),
      );

  void dispose() {
    fadeController?.dispose();
    expandController?.dispose();
    super.dispose();
  }
}
