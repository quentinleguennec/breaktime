import 'package:aebeze/app_constants.dart';
import 'package:aebeze/mood_selector/navigation_buttons.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// For use as a Scaffold appbar.
/// If not used as a Scaffold appbar (even if in the Scaffold), use [NavigationAppBarOverlay] instead.
class NavigationAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double height = 40 + (defaultIconTapSize + navigationButtonIconSize) * 0.5;

  final VoidCallback onPressed;
  final String title;
  final Color backgroundColor;
  final bool withInvertedColor;
  final bool isCancel;
  final bool isStatusBarTextWhite;

  const NavigationAppBar({
    this.title,
    this.backgroundColor,
    this.onPressed,
    this.withInvertedColor = false,
    this.isCancel = true,
    this.isStatusBarTextWhite = false,
  });

  Color get _backgroundColor => backgroundColor ?? AppColors.scaffoldBackgroundColor;

  /// This might seem inverted! Read under.
  /// This is supposed to reflect the brightness of the appbar, so if set to [Brightness.light] it will make the status bar black to contrast.
  Brightness get brightness => isStatusBarTextWhite ? Brightness.dark : Brightness.light;

  @override
  Widget build(BuildContext context) => AppBar(
        brightness: brightness,
        automaticallyImplyLeading: false,
        backgroundColor: _backgroundColor,
        centerTitle: false,
        elevation: 0,
        titleSpacing: 0,
        flexibleSpace: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            alignment: Alignment.bottomLeft,
            height: defaultIconTapSize,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30 - (defaultIconTapSize - navigationButtonIconSize) * 0.5),
                  child: isCancel
                      ? CancelNavigationButton(
                          onTap: onPressed ?? () => Navigator.of(context).pop(),
                          withInvertedColor: withInvertedColor,
                        )
                      : BackNavigationButton(
                          onTap: onPressed ?? () => Navigator.of(context).pop(),
                          withInvertedColor: withInvertedColor,
                        ),
                ),
                TextScaled(
                  title ?? "",
                  style: AppTextStyles.h5.copyWith(
                    color: withInvertedColor ? AppColors.invertedColorFaded : AppColors.baseColorFaded,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      );

  @override
  Size get preferredSize => const Size.fromHeight(height);
}

/// Use this Navigation bar when you need to embed in a [Stack].
class NavigationAppBarOverlay extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool withInvertedColor;
  final bool isCancel;
  final bool isStatusBarTextWhite;

  const NavigationAppBarOverlay({
    this.title,
    this.onPressed,
    this.withInvertedColor = false,
    this.isCancel = true,
    this.isStatusBarTextWhite = false,
  });

  @override
  Widget build(BuildContext context) => MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        removeTop: true,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top) * 0.5,
          child: Container(
            height: NavigationAppBar.height,
            width: MediaQuery.of(context).size.width,
            child: NavigationAppBar(
              isStatusBarTextWhite: isStatusBarTextWhite,
              onPressed: onPressed,
              title: title,
              withInvertedColor: withInvertedColor,
              isCancel: isCancel,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      );
}
