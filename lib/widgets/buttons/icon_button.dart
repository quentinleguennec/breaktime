import 'dart:io';
import 'dart:math' as math;

import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CloseIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final double containerWidth;
  final double containerHeight;
  final Color color;

  CloseIconButton({this.onPressed, this.size, this.containerWidth, this.containerHeight, this.color = Colors.white});

  @override
  Widget build(BuildContext context) => BasicIconButton(
        width: containerWidth,
        height: containerHeight,
        icon: Icon(Icons.close, color: color, size: size),
        onPressed: onPressed == null ? () => Navigator.of(context).pop() : onPressed,
      );
}

class ArrowIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int quarterTurns;
  final bool isDownArrow;
  final Color color;

  ArrowIconButton({
    this.onPressed,
    this.quarterTurns = 0,
    this.isDownArrow = false,
    this.color,
  });

  Color get _color => color ?? AppColors.baseColor;

  @override
  Widget build(BuildContext context) => BasicIconButton(
        width: defaultIconTapSize,
        height: defaultIconTapSize,
        icon: isDownArrow
            ? Image.asset(
                Assets.chevronDown,
                width: 24.0,
                height: 24.0,
                color: _color,
              )
            : Image.asset(
                Assets.iconBack,
                width: 18.0,
                height: 18.0,
                color: _color,
              ),
        onPressed: onPressed == null ? () => Navigator.of(context).pop() : onPressed,
        quarterTurns: quarterTurns,
      );
}

class SwipeUpIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;
  final int quarterTurns;
  final PageContext pageContext;
  final SwipeUpIconButtonController controller;

  SwipeUpIconButton({
    @required this.onPressed,
    this.color = Colors.white,
    this.quarterTurns = 0,
    this.pageContext,
    this.controller,
  });

  @override
  _State createState() => _State();
}

class _State extends SafeState<SwipeUpIconButton> with SingleTickerProviderStateMixin {
  AnimationController animationController;

  PageContext get pageContext => widget.pageContext;

  SwipeUpIconButtonController get controller => widget.controller;

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(refreshState);
    controller?.addListener(onControllerUpdated);
    super.initState();
  }

  void onControllerUpdated() => toggle();

  void toggle() => animationController.status == AnimationStatus.dismissed
      ? animationController.forward()
      : animationController.reverse();

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?.removeListener(onControllerUpdated);
    controller?.addListener(onControllerUpdated);
  }

  @override
  void dispose() {
    controller?.removeListener(onControllerUpdated);
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Transform(
        transform: Matrix4.rotationX(-math.pi * animationController.value),
        alignment: Alignment.center,
        child: BasicIconButton(
          width: defaultIconTapSize,
          height: defaultIconTapSize,
          icon: Image.asset(
            Assets.chevronFlatter,
            width: 30.0,
            height: 30.0,
            color: widget.color,
          ),
          onPressed: widget.onPressed,
          quarterTurns: widget.quarterTurns,
        ),
      );
}

class SwipeUpIconButtonController extends ChangeNotifier {
  void toggle() => notifyListeners();
}

class BasicIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final int quarterTurns;
  final double width;
  final double height;

  BasicIconButton({@required this.icon, this.onPressed, this.quarterTurns = 0, this.width, this.height});

  @override
  Widget build(BuildContext context) => RotatedBox(
        quarterTurns: quarterTurns,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: onPressed == null ? null : (_) => onPressed(),
          child: Container(
            alignment: Alignment.center,
            width: width,
            height: height,
            child: icon,
          ),
        ),
      );
}

class ShareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  ShareButton({
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) => BasicIconButton(
        width: defaultIconTapSize,
        height: defaultIconTapSize,
        icon: Icon(
          Platform.isIOS ? CupertinoIcons.share : Icons.share,
          color: color,
          size: Platform.isIOS ? 36 : 30,
        ),
        onPressed: onPressed,
      );
}
