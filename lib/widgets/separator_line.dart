import 'package:aebeze/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SeparatorLine extends StatelessWidget {
  final Color color;

  const SeparatorLine({this.color});

  factory SeparatorLine.baseVeryFaded() => SeparatorLine(color: AppColors.baseColor.withOpacity(0.1));

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        color: color ?? Colors.white.withOpacity(0.3),
      );
}
