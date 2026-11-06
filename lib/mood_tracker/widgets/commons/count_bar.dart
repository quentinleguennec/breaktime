import 'dart:ui';

import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CountBar extends StatelessWidget {
  /// The bar will fill at least this much no matter the value of [fillRatio].
  /// This is to make sure the text is in the bar.
  static const _minFillRatio = 0.30;
  final double fillRatio;
  final String text;
  final Color color;

  const CountBar({
    @required fillRatio,
    @required this.text,
    @required this.color,
  }) : fillRatio = fillRatio > _minFillRatio ? fillRatio : _minFillRatio;

  @override
  Widget build(BuildContext context) => Container(
        height: 30,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => Padding(
                  padding: EdgeInsets.only(right: constraints.biggest.width * (1 - fillRatio)),
                  child: Container(
                    width: constraints.biggest.width,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: TextScaled(
                  text,
                  style: AppTextStyles.bodyZirkonRegular.copyWith(color: Color(0xFF232323)),
                ),
              ),
            ),
          ],
        ),
      );
}
