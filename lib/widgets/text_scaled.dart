import 'package:aebeze/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Normal [Text] widget which overrides [textScaleFactor].
///
/// Prevents the text from being too big if the user changes the device's text size setting.
class TextScaled extends StatelessWidget {
  final String data;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final String semanticsLabel;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior textHeightBehavior;

  const TextScaled(
    this.data, {
    Key key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : assert(data != null);

  @override
  Widget build(BuildContext context) => Text(
        data ?? "",
        textScaleFactor: textScaleFactor ?? MediaQuery.textScaleFactorOf(context).clamp(0.0, maxTextScaleFactor),
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      );
}
