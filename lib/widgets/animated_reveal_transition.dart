import 'package:flutter/material.dart';

enum AnimatedRevealTransitionWidgetDirection {
  vertical,
  horizontal,
}

/// Play a transition that fades-in and translates up to down.
class AnimatedRevealTransitionWidget extends AnimatedWidget {
  final Widget child;
  final Animation<double> animation;
  final double translationValue;
  final double opacityValue;
  final AnimatedRevealTransitionWidgetDirection direction;

  AnimatedRevealTransitionWidget({
    @required this.child,
    @required this.animation,
    this.translationValue = 10.0,
    this.opacityValue = 1.0,
    this.direction = AnimatedRevealTransitionWidgetDirection.vertical,
  }) : super(listenable: animation);

  double get _currentTranslationValue => animation.value * translationValue - translationValue;

  Matrix4 get _transform => direction == AnimatedRevealTransitionWidgetDirection.vertical
      ? Matrix4.translationValues(0.0, _currentTranslationValue, 0.0)
      : Matrix4.translationValues(_currentTranslationValue, 0.0, 0.0);

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacityValue == null ? 1.0 : animation.value * opacityValue,
        child: Transform(
          transform: _transform,
          child: child,
        ),
      );
}

/// Use this to get a controller and a number of animations to assign to a group of [AnimatedRevealTransitionWidget].
/// Each animation will play one after the other in a cascading fashion.
class AnimatedRevealTransitionController extends AnimationController {
  List<Animation<double>> _animations;
  int _animationsCount;
  Duration _baseDuration;
  Duration _delay;
  int nextAnimationIndex = 0;

  int get animationsCount => _animationsCount;

  set animationsCount(int count) {
    if (count != _animationsCount) {
      _animationsCount = count;
      nextAnimationIndex = 0;
      _updateValues();
    }
  }

  Duration get baseDuration => _baseDuration;

  set baseDuration(Duration duration) {
    if (duration != _baseDuration) {
      _baseDuration = duration;
      _updateValues();
    }
  }

  Duration get delay => _delay;

  set delay(Duration duration) {
    if (duration != _delay) {
      _delay = duration;
      _updateValues();
    }
  }

  Animation<double> get nextAnimation {
    Animation<double> animation = _animations[nextAnimationIndex];
    nextAnimationIndex++;
    if (nextAnimationIndex >= _animations.length) nextAnimationIndex = 0;
    return animation;
  }

  Animation<double> get currentAnimation {
    int currentAnimationIndex;
    if (nextAnimationIndex == 0) {
      currentAnimationIndex = _animations.length - 1;
    } else {
      currentAnimationIndex = nextAnimationIndex - 1;
    }
    return _animations[currentAnimationIndex];
  }

  AnimatedRevealTransitionController({
    @required TickerProvider vsync,
    @required int animationsCount,
    Duration baseDuration = const Duration(milliseconds: 300),
    Duration delay = const Duration(milliseconds: 50),
  }) : super(vsync: vsync) {
    this._animationsCount = animationsCount;
    this._delay = delay;
    this._baseDuration = baseDuration;
    _updateValues();
  }

  void _updateValues() {
    _animations = List<Animation<double>>(_animationsCount);
    final Duration totalDuration = _baseDuration + _delay * (_animationsCount - 1);
    super.duration = totalDuration;
    for (int i = 0; i < _animationsCount; i++) {
      _animations[i] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: this,
          curve: Interval(
            _delay.inMilliseconds * i / totalDuration.inMilliseconds,
            (_delay.inMilliseconds * i + _baseDuration.inMilliseconds) / totalDuration.inMilliseconds,
          ),
        ),
      );
    }
  }
}
