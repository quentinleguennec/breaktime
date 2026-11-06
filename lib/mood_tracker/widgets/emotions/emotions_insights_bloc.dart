import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:aebeze/bloc_pattern/bloc.dart';
import 'package:aebeze/bloc_pattern/bloc_single_ticker_provider_mixin.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EmotionsInsightsBloc extends Bloc with BlocSingleTickerProviderStateMixin {
  final _streamController = StreamController<EmotionsInsightsState>();
  EmotionsInsightsState _state;
  AnimationController _animationController;
  EmotionsInsightsState _stateBeforeAnimation;
  EmotionsInsightsState _stateAfterAnimation;

  EmotionsInsightsBloc() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(_animateValues);

    _state = EmotionsInsightsState.empty();

    _streamController.sink.add(_state);
  }

  EmotionsInsightsState get state => _state;

  Stream<EmotionsInsightsState> get stream => _streamController.stream;

  void startAnimation({
    @required String newMainEmotion,
    @required int newMainEmotionCountThisWeek,
    @required int newMainEmotionCountLastWeek,
  }) {
    String mainEmotion = newMainEmotion ?? "";
    int mainEmotionCountThisWeek = newMainEmotionCountThisWeek ?? 0;
    int mainEmotionCountLastWeek = newMainEmotionCountLastWeek ?? 0;

    _stateBeforeAnimation = EmotionsInsightsState(
      mainEmotion: state.mainEmotion,
      mainEmotionCountThisWeek: state.mainEmotionCountThisWeek,
      mainEmotionCountLastWeek: state.mainEmotionCountLastWeek,
      thisWeekBarFillRatio: state.thisWeekBarFillRatio,
      lastWeekBarFillRatio: state.lastWeekBarFillRatio,
    );

    double thisWeekBarFillRatio;
    double lastWeekBarFillRatio;

    if (mainEmotionCountThisWeek != 0 || mainEmotionCountLastWeek != 0) {
      int maxCount = max(mainEmotionCountThisWeek, mainEmotionCountLastWeek);
      thisWeekBarFillRatio = mainEmotionCountThisWeek / maxCount;
      lastWeekBarFillRatio = mainEmotionCountLastWeek / maxCount;
    }

    _stateAfterAnimation = EmotionsInsightsState(
      mainEmotion: mainEmotion,
      mainEmotionCountThisWeek: mainEmotionCountThisWeek.toDouble(),
      mainEmotionCountLastWeek: mainEmotionCountLastWeek.toDouble(),
      thisWeekBarFillRatio: thisWeekBarFillRatio,
      lastWeekBarFillRatio: lastWeekBarFillRatio,
    );

    _updateState(state.copyWith(mainEmotion: mainEmotion));

    _animationController.forward(from: 0);
  }

  void _animateValues() {
    _updateState(
      state.copyWith(
        mainEmotionCountThisWeek: lerpDouble(
          _stateBeforeAnimation.mainEmotionCountThisWeek,
          _stateAfterAnimation.mainEmotionCountThisWeek,
          _animationController.value,
        ),
        mainEmotionCountLastWeek: lerpDouble(
          _stateBeforeAnimation.mainEmotionCountLastWeek,
          _stateAfterAnimation.mainEmotionCountLastWeek,
          _animationController.value,
        ),
        thisWeekBarFillRatio: lerpDouble(
          _stateBeforeAnimation.thisWeekBarFillRatio,
          _stateAfterAnimation.thisWeekBarFillRatio,
          _animationController.value,
        ),
        lastWeekBarFillRatio: lerpDouble(
          _stateBeforeAnimation.lastWeekBarFillRatio,
          _stateAfterAnimation.lastWeekBarFillRatio,
          _animationController.value,
        ),
      ),
    );
  }

  void _updateState(EmotionsInsightsState newState) {
    _state = newState;
    _streamController.sink.add(_state);
  }

  @override
  void dispose() {
    _streamController.close();
    _animationController.dispose();
  }
}

@immutable
class EmotionsInsightsState {
  static const _emptyEmotion = " ";

  final String mainEmotion;
  final double mainEmotionCountThisWeek;
  final double mainEmotionCountLastWeek;
  final double thisWeekBarFillRatio;
  final double lastWeekBarFillRatio;

  bool get isEmpty => isEmptyOrNull(mainEmotion) || mainEmotion == _emptyEmotion;

  EmotionsInsightsState({
    this.mainEmotion,
    this.mainEmotionCountThisWeek,
    this.mainEmotionCountLastWeek,
    this.thisWeekBarFillRatio,
    this.lastWeekBarFillRatio,
  });

  factory EmotionsInsightsState.empty() => EmotionsInsightsState(
        mainEmotion: _emptyEmotion,
        mainEmotionCountThisWeek: 0,
        mainEmotionCountLastWeek: 0,
        thisWeekBarFillRatio: 0.5,
        lastWeekBarFillRatio: 0.5,
      );

  EmotionsInsightsState copyWith({
    String mainEmotion,
    double mainEmotionCountThisWeek,
    double mainEmotionCountLastWeek,
    double thisWeekBarFillRatio,
    double lastWeekBarFillRatio,
  }) =>
      EmotionsInsightsState(
        mainEmotion: mainEmotion ?? this.mainEmotion,
        mainEmotionCountThisWeek: mainEmotionCountThisWeek ?? this.mainEmotionCountThisWeek,
        mainEmotionCountLastWeek: mainEmotionCountLastWeek ?? this.mainEmotionCountLastWeek,
        thisWeekBarFillRatio: thisWeekBarFillRatio ?? this.thisWeekBarFillRatio,
        lastWeekBarFillRatio: lastWeekBarFillRatio ?? this.lastWeekBarFillRatio,
      );
}
