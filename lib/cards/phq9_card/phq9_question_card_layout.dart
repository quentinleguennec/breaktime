import 'dart:ui';

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/buttons/menu_button.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class PHQ9QuestionCardLayout extends BasicCardLayout {
  static final String text = "text";
  static final String buttons = "buttons";
  final ValueChanged<int> onQuestionAnswered;

  PHQ9QuestionCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded, this.onQuestionAnswered)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundImage(context, layoutChild, size, positionChild);
    layoutBackgroundVideo(context, size, layoutChild, positionChild);
    layoutText(context, size, layoutChild, positionChild);
    layoutButtons(context, size, layoutChild, positionChild);
  }

  void layoutText(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(text, BoxConstraints.tightFor(width: size.width));
    positionChild(
      text,
      Offset(
        0.0,
        MediaQuery.of(context).padding.top + (size.width < defaultScreenWidth ? 60.0 : 120),
      ),
    );
  }

  void layoutButtons(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    Size buttonsSize = layoutChild(buttons, BoxConstraints.tightFor(width: size.width));
    positionChild(
      buttons,
      Offset(
        (size.width - buttonsSize.width) * 0.5,
        size.height - buttonsSize.height - defaultPadding - MediaQuery.of(context).padding.bottom,
      ),
    );
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundImage(list);
    addBackgroundVideo(list);
    addText(list);
    addButtons(list);
    return list;
  }

  void addText(LayoutList list) {
    list.layout(text, () => _Text(card));
  }

  void addButtons(LayoutList list) {
    list.layout(buttons, () => _Buttons(card, onQuestionAnswered));
  }
}

class _Text extends StatelessWidget {
  final DataCard card;

  _Text(this.card);

  // On small screen the text is too big.
  double getTextScale(BuildContext context) => MediaQuery.of(context).size.width < defaultScreenWidth
      ? MediaQuery.of(context).size.width / defaultScreenWidth
      : null;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(
        left: defaultPadding,
        right: defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: TextScaled(
              card.placement.header.toUpperCase(),
              style: AppTextStyles.subhead,
            ),
          ),
          TextScaled(
            card.placement.content,
            style: AppTextStyles.h2,
            textScaleFactor: getTextScale(context),
          ),
        ],
      ));
}

class _Buttons extends StatelessWidget {
  final DataCard card;
  final ValueChanged<int> onQuestionAnswered;

  _Buttons(
    this.card,
    this.onQuestionAnswered,
  );

  List<Widget> get columnChildren {
    List<Widget> children = List();

    /// Hijacking the message field here to store the questions (harmless hack).
    for (int i = 0; i < card.messages.length; i++) {
      int questionWeight = card.messages.length - i - 1;
      children.add(
        _Button(
          text: card.messages[i].message,
          onPressed: () => onQuestionAnswered(questionWeight),
        ),
      );
      if (i != card.messages.length - 1) {
        children.add(Padding(padding: const EdgeInsets.only(bottom: 10.0)));
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) => Column(
        children: columnChildren,
      );
}

class _Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  _Button({
    @required this.text,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: MenuButton(
              text,
              isLocalizedText: false,
              backgroundColor: Colors.black.withOpacity(0.12),
              borderColor: Colors.transparent,
              textColor: Colors.black,
              onTap: onPressed,
            ),
          ),
        ),
      );
}
