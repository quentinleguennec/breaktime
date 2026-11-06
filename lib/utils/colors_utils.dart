import 'dart:ui';

import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:flutter/material.dart';

Color stringToColor(String color) {
  if (color == null) {
    return null;
  }
  try {
    color = normalizeColor(color);
    int a = int.parse(color.substring(2, 4), radix: 16);
    int r = int.parse(color.substring(4, 6), radix: 16);
    int g = int.parse(color.substring(6, 8), radix: 16);
    int b = int.parse(color.substring(8, 10), radix: 16);
    return Color.fromARGB(a, r, g, b);
  } catch (e) {
    print("Color convertion error: Color string = $color \nError = $e");
    return Colors.white;
  }
}

String colorToString(Color color) {
  if (color == null) {
    return null;
  }
  return normalizeColor("#" + color.value.toRadixString(16).padLeft(8, '0'));
}

String normalizeColor(String color) {
  if (color.startsWith("#")) {
    color = color.replaceFirst("#", "0x");
    if (color.length == 8) {
      color = color.replaceFirst("0x", "0xFF");
    }
  }
  return color;
}

Color bestFontColorForCard(DataCard card) {
  if (card.background == null || card.background.color == null) return Colors.black;
  return bestFontColor(card.background.color);
}

Color bestFontColor(String backgroundColor) {
  if (backgroundColor == null) {
    return Colors.black;
  }
  try {
    String color = normalizeColor(backgroundColor);
    int r = int.parse(color.substring(4, 6), radix: 16);
    int g = int.parse(color.substring(6, 8), radix: 16);
    int b = int.parse(color.substring(8, 10), radix: 16);
    return (r * 0.299 + g * 0.587 + b * 0.114) > 186 ? Colors.black : Colors.white;
  } catch (e) {
    print("bestFontColor error: Color string = $backgroundColor \nError = $e");
    return Colors.black;
  }
}

Color cardBackgroundColor(DataCard card) {
  return card == null || card.background == null
      ? AppColors.scaffoldBackgroundColor
      : stringToColor(card.background.color) ?? AppColors.scaffoldBackgroundColor;
}

Color backgroundColor(Background background) {
  return background == null
      ? AppColors.scaffoldBackgroundColor
      : stringToColor(background.color) ?? AppColors.scaffoldBackgroundColor;
}

Color cardOpposingColor(Background background) => background == null ? Colors.black : bestFontColor(background.color);

Color placementOpposingColor(DataCard card, Placement p) => p.background != null && p.background.color != null
    ? bestFontColor(p.background.color)
    : cardOpposingColor(card.background);

/// When you want to have a color look lighter without having opacity.
Color rgba2rgb(Color color, {Color backgroundColor = Colors.white}) => Color.fromARGB(
      255,
      ((1 - color.opacity) * backgroundColor.red + color.opacity * color.red).round(),
      ((1 - color.opacity) * backgroundColor.green + color.opacity * color.green).round(),
      ((1 - color.opacity) * backgroundColor.blue + color.opacity * color.blue).round(),
    );
