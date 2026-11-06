import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StoryProgress extends StatelessWidget {
  final DataCard card;
  final CardAnimator animator;

  StoryProgress(this.card, this.animator);

  @override
  Widget build(BuildContext context) {
    Color color = card.storyTextColor == null ? bestFontColorForCard(card) : stringToColor(card.storyTextColor);
    return Padding(
      padding: const EdgeInsets.only(right: defaultPadding, left: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Indicator(card.storyPosition, card.storyLength, color, animator.placementsAnimation),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final int storyLength;
  final int storyPosition;
  final Color color;
  final Animation<double> animationValue;

  _Indicator(this.storyPosition, this.storyLength, this.color, this.animationValue);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.tightFor(
        width: double.infinity,
        height: 1.0,
      ),
      child: CustomPaint(
        painter: _IndicatorPainter(storyPosition, storyLength, color, animationValue),
      ),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  final int storyLength;
  final int storyPosition;
  final Color color;
  final Animation<double> animation;

  _IndicatorPainter(this.storyPosition, this.storyLength, this.color, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = color.withOpacity(0.50);
    Size sizeBar =
        Size(size.width * ((storyPosition - 1) / storyLength) + (size.width / storyLength) * animation.value, 1.0);
    canvas.drawRect(Offset.zero & sizeBar, paint);
  }

  @override
  bool shouldRepaint(_IndicatorPainter painter) {
    return painter.storyPosition != storyPosition ||
        painter.storyLength != storyLength ||
        painter.animation != animation;
  }
}
