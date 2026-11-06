import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/widgets/card_instruction_button.dart';
import 'package:aebeze/widgets/buttons/card_timer.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardNextButton extends StatefulWidget {
  final PageContext pageContext;

  CardNextButton({@required this.pageContext});

  @override
  _State createState() => _State();
}

class _State extends SafeState<CardNextButton> with SingleTickerProviderStateMixin {
  static const Duration animationDuration = const Duration(milliseconds: 300);

  AnimationController animationController;

  PageContext get pageContext => widget.pageContext;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: animationDuration);
    animationController.addListener(refreshState);
    pageContext.cardTimerController?.addListener(onCardTimerUpdated);
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.cardTimerController?.removeListener(onCardTimerUpdated);
    pageContext.cardTimerController?.addListener(onCardTimerUpdated);
  }

  @override
  void dispose() {
    animationController?.dispose();
    pageContext.cardTimerController?.removeListener(onCardTimerUpdated);
    super.dispose();
  }

  void onCardTimerUpdated() {
    if (pageContext.cardTimerController.status == TimerStatus.completed) {
      animationController.forward();
    } else if (pageContext.cardTimerController.status == TimerStatus.dismissed) {
      animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => Visibility(
        visible: animationController.status != AnimationStatus.dismissed,
        child: Opacity(
          opacity: animationController.value,
          child: CardInstructionButton(
            text: localize(context, "button_next").toUpperCase(),
            onPressed: pageContext.onNextPressed,
          ),
        ),
      );
}
