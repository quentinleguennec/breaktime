import 'package:flutter/material.dart';

import 'app.dart';

class AppColors {
  AppColors._();

  static final Color tealish = App.isDayBreak ? const Color(0xFF65C5FA) : const Color(0xFF00AEEF);
  static final Color warmGrey = App.isDayBreak ? const Color(0xFFB4B4B4) : const Color(0xFF9B9B9B);
  static const Color veryLightGrey = const Color(0xFFDEDEDE);
  static const Color brilliant = const Color(0xFFF9F7F5);
  static const Color iceBlue = const Color(0xFF35c8ff);
  static const Color offWhite = const Color(0xFFFFFBEB);
  static const Color lightCyan = const Color(0xFFACF2F9);
  static const Color daybreakYellow = const Color(0xFFF4F74B);
  static final Color accentColor = App.isDayBreak ? daybreakYellow : tealish;
  static final Color whiteFaded = Colors.white.withOpacity(0.95);
  static final Color blackFaded = Colors.black.withOpacity(0.95);
  static final Color whiteVeryFaded = Colors.white.withOpacity(0.55);
  static final Color blackVeryFaded = Colors.black.withOpacity(0.55);

  //Well defined
  static final Color scaffoldBackgroundColor = App.isDayBreak ? const Color(0xFF222222) : Colors.white;
  static final Color canvasColor = App.isDayBreak ? const Color(0xFF616161) : Colors.white;
  static final Color baseColor = App.isDayBreak ? Colors.white : Colors.black;
  static final Color baseColorFaded = App.isDayBreak ? whiteFaded : blackFaded;
  static final Color baseColorVeryFaded = App.isDayBreak ? whiteVeryFaded : blackVeryFaded;
  static final Color invertedColor = App.isDayBreak ? Colors.black : Colors.white;
  static final Color invertedColorFaded = App.isDayBreak ? AppColors.blackFaded : AppColors.whiteFaded;
  static final Color buttonBackgroundColor = App.isDayBreak ? const Color(0xFF616161) : brilliant;
  static final Color textInputFieldBorder = App.isDayBreak ? daybreakYellow : blackVeryFaded;
  static final Color moodButtonBackgroundOn = AppColors.whiteFaded;
  static final Color moodButtonBackgroundOff = null;
  static final Color moodButtonTextOff = Colors.white.withOpacity(0.9);
  static final Color moodButtonTextOn = Colors.black.withOpacity(0.9);
  static final List<Color> logoTopColors = [Colors.white, Colors.grey.shade300, Color(0xFFACE0F9)];
  static final List<Color> logoBottomColors = [Colors.white, Color(0xFFFFF1EB)];
  static const Color daybreakSplash = const Color(0xFF0C0C0E);
  static const Color popupBackgroundColor = const Color(0x40000000);
  static const Color splashCircleInner = const Color(0xFFF4F0ED);
  static const Color splashCircleOuter = const Color(0xFFF9F7F5);
  static final Color transparentBoxBackgroundColor = Colors.white.withOpacity(0.12);
  static final Color pillcastListColor = App.isDayBreak ? const Color(0xFF373737) : brilliant;
  static final Color insightsWidgetGrey = App.isDayBreak ? const Color(0xFF7C7C7C) : warmGrey;
  static final Color pillcastPlayerText = const Color(0xFFF5F6FB);

  static final List<Color> backgroundGradientColors = App.isDayBreak
      ? [
          const Color(0xFF202020),
          const Color(0xFF373737),
        ]
      : [
          const Color(0xFF2056ED),
          const Color(0xFF7598FD),
        ];

  static final MaterialColor materialColorMap = App.isDayBreak
      ? MaterialColor(
          0xFFe4c7a1,
          const <int, Color>{
            50: Colors.black,
            100: Colors.black,
            200: Colors.black,
            300: Colors.black,
            400: Colors.black,
            500: Colors.black,
            600: Colors.black,
            700: Colors.black,
            800: Colors.black,
            900: Colors.black,
          },
        )
      : MaterialColor(
          0xFFe4c7a1,
          const <int, Color>{
            50: Colors.white,
            100: Colors.white,
            200: Colors.white,
            300: Colors.white,
            400: Colors.white,
            500: Colors.white,
            600: Colors.white,
            700: Colors.white,
            800: Colors.white,
            900: Colors.white,
          },
        );
}

final ThemeData appThemeData = ThemeData(
  splashColor: Colors.transparent,
  primaryColor: Colors.white,
  primarySwatch: AppColors.materialColorMap,
  scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
  textSelectionColor: AppColors.tealish,
  textSelectionHandleColor: AppColors.tealish,
  canvasColor: AppColors.canvasColor,
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    color: Colors.transparent,
    elevation: 0,
  ),
);

class AppTextStyles {
  static final TextStyle h1 = TextStyle(
    color: AppColors.baseColor,
    fontSize: 48.0,
    fontFamily: "BeatriceDisplaySemiBold",
  );

  static TextStyle get h1Huge => h1.copyWith(fontSize: 56.0);

  static final TextStyle h2 = TextStyle(
    color: AppColors.baseColor,
    fontSize: 28.0,
    letterSpacing: -0.4,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static final TextStyle h3 = TextStyle(
    color: AppColors.baseColor,
    fontSize: 26.0,
    letterSpacing: 0.2,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static TextStyle get h3ZirkonRegular => h3.copyWith(fontFamily: "ZirkonRegular");

  static TextStyle get h3Small => h3.copyWith(fontSize: 24);

  static TextStyle get h3SmallProtoGroteskLight => h3Small.copyWith(fontFamily: "ProtoGroteskLight");

  static final TextStyle h4 = TextStyle(
    color: AppColors.baseColor,
    fontSize: 20,
    letterSpacing: 0.2,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static TextStyle get h4ZirkonRegular => h4.copyWith(fontFamily: "ZirkonRegular");

  static final TextStyle h5 = TextStyle(
    color: AppColors.baseColorFaded,
    fontSize: 17.0,
    letterSpacing: 0.2,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static TextStyle get h5ZirkonRegular => h5.copyWith(fontFamily: "ZirkonRegular");

  static final TextStyle h6 = TextStyle(
    color: AppColors.baseColor,
    fontSize: 15.0,
    letterSpacing: 0.2,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static TextStyle get h6ZirkonRegular => h6.copyWith(fontFamily: "ZirkonRegular");

  static final TextStyle h7 = TextStyle(
    color: AppColors.baseColorFaded,
    fontSize: 13.0,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static TextStyle get h7ZirkonRegular => h7.copyWith(fontFamily: "ZirkonRegular");

  static final TextStyle subhead = TextStyle(
    color: AppColors.baseColor,
    fontSize: 16.0,
    letterSpacing: 0.6,
    fontFamily: "PatronRegular",
  );

  static TextStyle get subheadSmall => subhead.copyWith(fontSize: 14.0);

  static final TextStyle bodyReg = TextStyle(
    color: AppColors.baseColor,
    fontSize: 15.0,
    letterSpacing: 0.2,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static TextStyle get bodyLight => bodyReg.copyWith(fontFamily: "PatronLight");

  static TextStyle get bodyZirkonRegular => bodyLight.copyWith(fontFamily: "ZirkonRegular");

  static TextStyle get bodyLightZirkonBook => bodyLight.copyWith(fontFamily: "ZirkonBook");

  static final TextStyle inputField = TextStyle(
    color: AppColors.baseColorFaded,
    fontSize: 17.0,
    fontFamily: "ZirkonRegular",
    height: 1.18,
  );

  static final TextStyle caption = TextStyle(
    color: AppColors.warmGrey,
    fontSize: 14.0,
    letterSpacing: 0.3,
    height: 1.2,
    fontFamily: "PatronRegular",
  );

  static TextStyle get captionBright => caption.copyWith(color: AppColors.baseColor);

  static TextStyle get captionZirkonRegular => caption.copyWith(fontFamily: "ZirkonRegular", fontSize: 15);

  static TextStyle get captionSmallZirkonRegular => captionZirkonRegular.copyWith(fontSize: 13.0);

  static TextStyle get captionZirkonBook => caption.copyWith(fontFamily: "ZirkonBook");

  static TextStyle get captionZirkonBookSmall => captionZirkonBook.copyWith(fontSize: 12.0);

  static TextStyle get captionSmall => caption.copyWith(fontSize: 12.0);

  static final TextStyle button = TextStyle(
    color: AppColors.tealish,
    fontSize: 16.0,
    letterSpacing: 0.6,
    fontFamily: "PatronRegular",
  );

  static final TextStyle instruction = TextStyle(
    color: AppColors.baseColor,
    fontSize: 14.0,
    letterSpacing: 0.6,
    fontFamily: "PatronRegular",
  );

  static final TextStyle medicinal = TextStyle(
    color: AppColors.baseColor,
    fontSize: 14.0,
    letterSpacing: 0.4,
    fontFamily: "PatronLight",
  );

  static final TextStyle startCardTitle = TextStyle(
    color: AppColors.baseColorFaded,
    fontSize: 40,
    height: 1,
    fontFamily: "ProtoGroteskLight",
  );

  static final TextStyle daybreakSplashScreenTitle = TextStyle(
    color: AppColors.baseColor,
    fontSize: 78,
    fontFamily: "GTSectraMedium",
  );

  static final TextStyle dashboardHeaderTitle = TextStyle(
    color: AppColors.baseColor.withOpacity(0.8),
    fontSize: 24,
    fontFamily: "GTSectraDisplayBold",
    fontWeight: FontWeight.w900,
  );

  static final TextStyle daybreakPHQ9Title = TextStyle(
    color: AppColors.baseColor,
    fontSize: 46,
    height: 1,
    fontFamily: "ProtoGroteskLight",
  );

  static final TextStyle bigTitle = TextStyle(
    color: AppColors.whiteFaded,
    fontSize: 40,
    height: 1,
    fontFamily: "ProtoGroteskLight",
  );

  static TextStyle get iconText => subhead.copyWith(fontFamily: "ZirkonRegular", fontSize: 11);

  static TextStyle get subCategory => bodyZirkonRegular.copyWith(color: Colors.white.withOpacity(0.6));

  static final TextStyle dashboardTreatmentListItemBenefits = TextStyle(
    color: App.isDayBreak ? AppColors.whiteFaded : AppColors.blackFaded,
    fontSize: 15,
    height: 1.3,
    fontFamily: "ZirkonRegular",
  );

  static final TextStyle dashboardTreatmentListItemActiveIngredient = TextStyle(
    color: AppColors.baseColorVeryFaded,
    fontSize: 13,
    fontFamily: "ZirkonRegular",
  );

  static final TextStyle smallText = TextStyle(
    color: Colors.white.withOpacity(0.6),
    fontSize: 13,
    fontFamily: "ZirkonRegular",
  );

  static final TextStyle moodSelectorCategoryTitle = TextStyle(
    color: Colors.white.withOpacity(0.6),
    fontSize: 15,
    fontFamily: "ZirkonRegular",
  );

  static final TextStyle startCardIngredientBriefHeader = TextStyle(
    color: AppColors.baseColor.withOpacity(App.isDayBreak ? 0.6 : 0.55),
    fontSize: 13,
    fontFamily: "ZirkonRegular",
  );
}

abstract class AppDecorations {
  static final BoxDecoration transparentBox = BoxDecoration(
    color: AppColors.transparentBoxBackgroundColor,
    borderRadius: BorderRadius.circular(2),
  );
}
