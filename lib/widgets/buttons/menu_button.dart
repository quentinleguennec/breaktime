import 'dart:async';

import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/progress_loader.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuButton extends StatefulWidget {
  static const double height = 54.0;

  final String text;
  final Color backgroundColor;
  final GestureTapCallback onTap;
  final double verticalPadding;
  final double horizontalPadding;
  final Color textColor;
  final Color borderColor;
  final bool isLoading;
  final Image icon;
  final bool isLocalizedText;
  final bool isShareButton;
  final bool preventHeldOpacity;

  MenuButton(
    this.text, {
    this.textColor = Colors.white,
    this.onTap,
    this.backgroundColor,
    this.verticalPadding = 0.0,
    this.horizontalPadding = 0.0,
    this.isLoading = false,
    this.isShareButton = false,
    this.icon,
    this.borderColor,
    this.isLocalizedText = true,
    this.preventHeldOpacity = false,
  });

  @override
  _State createState() => _State();
}

class _State extends SafeState<MenuButton> {
  static const double heldOpacity = 0.6;
  bool isHeld = false;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: isHeld ? heldOpacity : 1.0,
        child: GestureDetector(
          onTapDown: (_) => widget.preventHeldOpacity ? {} : setMountedState(() => isHeld = true),
          onTapCancel: () => widget.preventHeldOpacity ? {} : setMountedState(() => isHeld = false),
          onTap: () {
            if (!widget.preventHeldOpacity) {
              /// Add some time for the tap feedback to show.
              Future.delayed(const Duration(milliseconds: 100), () => setMountedState(() => isHeld = false));
            }
            if (widget.onTap != null && !widget.isLoading) {
              widget.onTap();
            }
          },
          child: Container(
            height: MenuButton.height,
            padding: EdgeInsets.symmetric(horizontal: widget.isShareButton ? 16.0 : 24.0),
            margin: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: widget.verticalPadding),
            decoration: BoxDecoration(
              border: widget.borderColor == null ? null : Border.all(color: widget.borderColor),
              borderRadius: BorderRadius.circular(27.0),
              color: widget.backgroundColor,
            ),
            child: Row(
              children: <Widget>[
                widget.icon == null ? Container() : widget.icon,
                Expanded(
                  child: widget.isLoading
                      ? ProgressLoader(color: widget.textColor)
                      : widget.isShareButton
                          ? Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: TextScaled(
                                widget.isLocalizedText
                                    ? localize(context, widget.text).toUpperCase()
                                    : widget.text.toUpperCase(),
                                style: AppTextStyles.button.apply(color: widget.textColor),
                                textAlign: TextAlign.left,
                              ),
                            )
                          : TextScaled(
                              widget.isLocalizedText
                                  ? localize(context, widget.text).toUpperCase()
                                  : widget.text.toUpperCase(),
                              style: AppTextStyles.button.apply(color: widget.textColor),
                              textAlign: TextAlign.center,
                            ),
                )
              ],
            ),
          ),
        ),
      );
}
