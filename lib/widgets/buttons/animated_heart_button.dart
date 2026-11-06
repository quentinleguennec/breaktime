import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/widgets/buttons/icon_button.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedHeartButton extends StatefulWidget {
  final bool isOn;
  final bool isHidden;
  final ValueGetter<bool> isAnimationDisabledGetter;
  final AnimatedHeartButtonController controller;
  final VoidCallback onPressed;

  AnimatedHeartButton({
    @required this.isOn,
    @required this.isAnimationDisabledGetter,
    this.isHidden = false,
    this.controller,
    this.onPressed,
  });

  @override
  _State createState() => _State();
}

class _State extends SafeState<AnimatedHeartButton> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> fadeInside;
  bool isHidden;

  static const Duration animationDuration = const Duration(milliseconds: 300);
  static const double size = 29.0;

  AnimatedHeartButtonController get controller => widget.controller;

  bool get isAnimationDisabled => widget.isAnimationDisabledGetter();

  @override
  void initState() {
    isHidden = widget.isHidden;

    animationController = AnimationController(vsync: this, duration: animationDuration);
    animationController.addListener(refreshState);

    controller?.addListener(onControllerUpdated);

    if (widget.isOn) {
      animationController.value = 1.0;
    }

    fadeInside = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller?.removeListener(onControllerUpdated);
    controller?.addListener(onControllerUpdated);
  }

  @override
  void dispose() {
    animationController?.dispose();
    controller?.removeListener(onControllerUpdated);
    super.dispose();
  }

  void onControllerUpdated() {
    if (controller._shouldHide == true && !isHidden) {
      setMountedState(() => isHidden = true);
    } else if (controller._shouldHide == false && isHidden) {
      setMountedState(() => isHidden = false);
    }

    if (animationController.isAnimating) return;

    if (controller._shouldTurnOn == true) {
      if (animationController.isDismissed) {
        playAnimation();
        return;
      }
    } else if (controller._shouldTurnOn == false) {
      if (animationController.isCompleted) {
        playAnimation();
        return;
      }
    }

    if (controller._shouldToggle == true) {
      playAnimation();
      return;
    }
  }

  void playAnimation() {
    if (isAnimationDisabled) return;

    if (animationController.isCompleted) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  void onPressed() {
    playAnimation();
    if (widget.onPressed != null) widget.onPressed();
  }

  @override
  Widget build(BuildContext context) => Visibility(
        visible: !isHidden,
        child: GestureDetector(
          onTap: onPressed,
          child: Row(
            children: <Widget>[
              BasicIconButton(
                width: defaultIconTapSize,
                height: defaultIconTapSize,
                icon: Stack(
                  children: <Widget>[
                    Image.asset(
                      Assets.iconHeartOutline,
                      width: size,
                    ),
                    Opacity(
                      opacity: fadeInside.value,
                      child: Image.asset(
                        Assets.iconHeart,
                        width: size,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class AnimatedHeartButtonController extends ChangeNotifier {
  bool _shouldTurnOn;
  bool _shouldToggle;
  bool _shouldHide;

  void toggle() {
    if (_shouldToggle != null) return;
    _shouldToggle = true;
    notifyListeners();
    _shouldToggle = null;
  }

  void turnOn() {
    if (_shouldTurnOn == true) return;
    _shouldTurnOn = true;
    notifyListeners();
    _shouldTurnOn = null;
  }

  void turnOff() {
    if (_shouldTurnOn == false) return;
    _shouldTurnOn = false;
    notifyListeners();
    _shouldTurnOn = null;
  }

  void hide() {
    if (_shouldHide == true) return;
    _shouldHide = true;
    notifyListeners();
    _shouldHide = null;
  }

  void show() {
    if (_shouldHide == false) return;
    _shouldHide = false;
    notifyListeners();
    _shouldHide = null;
  }
}
