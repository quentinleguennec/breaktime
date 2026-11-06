import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:flutter/material.dart';

const String aebezeUrl = "https://www.aebeze.com";
const String cardShareUrl = aebezeUrl + "/card?uid=";

const String aebezeAndroidAppId = "com.aebeze";
const String aebezeIosAppId = "1400832226";

/// The minimum size an icon's [GestureDetector] should have to be touched easily.
const double defaultIconTapSize = 48.0;

/// Used to scale the text based on screen size.
const double defaultScreenWidth = 375.0;
const double defaultScreenHeight = 667.0;

/// Used to clamp the max value of the text scale when the users change it in their device settings.
///
/// This avoids the layout looking ugly for big text scales.
const double maxTextScaleFactor = 1.15;

final DataCard errorCard = DataCard(
  uid: "errorCard",
  type: "error",
  description: "Content couldn’t load.\nWe apologise profusely.",
  activeIngredients: [ActiveIngredient(code: "Er", name: "Error")],
  title: "Error",
  background: Background(color: colorToString(AppColors.scaffoldBackgroundColor)),
  duration: const Duration(milliseconds: 300),
  placement: Placement(
    header: "Nothing but dark matter here.",
    content: "Content couldn’t load - we apologise profusely.",
    background: Background(color: colorToString(Colors.white)),
  ),
);

/// Default padding size to the edges of the screen.
const double defaultPadding = 20;
const double bigPadding = 24;
const double hugePadding = 32;
const double smallPadding = 16;
