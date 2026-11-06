import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:aebeze/bloc_pattern/bloc.dart';
import 'package:aebeze/bloc_pattern/bloc_single_ticker_provider_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WeeklyCheckinsInsightsBloc extends Bloc with BlocSingleTickerProviderStateMixin {
  final _streamController = StreamController<WeeklyCheckinsInsightsState>();
  WeeklyCheckinsInsightsState _state;
  AnimationController _animationController;
  WeeklyCheckinsInsightsState _stateBeforeAnimation;
  WeeklyCheckinsInsightsState _stateAfterAnimation;

  WeeklyCheckinsInsightsBloc() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(_animateValues);

    int dayOfTheWeekIndex = DateTime.now().weekday;
    if (dayOfTheWeekIndex == 7) {
      /// DateTime.now().weekday start on a monday and we want to start on sunday.
      dayOfTheWeekIndex = 0;
    }
    List<double> defaultValues = List.generate(dayOfTheWeekIndex + 1, (_) => 1.0);

    _state = new WeeklyCheckinsInsightsState(
      thisWeekValues: defaultValues,
      lastWeekValues: defaultValues,
      maxValue: 2,
      thisWeekCheckinsCount: 0,
      lastWeekCheckinsCount: 0,
    );

    _streamController.sink.add(_state);
  }

  WeeklyCheckinsInsightsState get state => _state;

  Stream<WeeklyCheckinsInsightsState> get stream => _streamController.stream;

  void startAnimation({
    @required int newThisWeekCheckinsCount,
    @required int newLastWeekCheckinsCount,
    @required List<double> newThisWeekValues,
    @required List<double> newLastWeekValues,
  }) {
    List<double> thisWeekValuesBeforeAnimation = List.from(state.thisWeekValues);
    List<double> lastWeekValuesBeforeAnimation = List.from(state.lastWeekValues);
    double maxValue = 1.0 +
        max(
          newThisWeekValues.isEmpty ? 0.0 : _getListMaxValue(newThisWeekValues),
          newLastWeekValues.isEmpty ? 0.0 : _getListMaxValue(newLastWeekValues),
        );

    _stateBeforeAnimation = new WeeklyCheckinsInsightsState(
      thisWeekValues: thisWeekValuesBeforeAnimation,
      lastWeekValues: lastWeekValuesBeforeAnimation,
      maxValue: state.maxValue,
      thisWeekCheckinsCount: state.thisWeekCheckinsCount,
      lastWeekCheckinsCount: state.lastWeekCheckinsCount,
    );

    _stateAfterAnimation = new WeeklyCheckinsInsightsState(
      thisWeekValues: newThisWeekValues,
      lastWeekValues: newLastWeekValues,
      maxValue: maxValue,
      thisWeekCheckinsCount: newThisWeekCheckinsCount,
      lastWeekCheckinsCount: newLastWeekCheckinsCount,
    );

    _animationController.forward(from: 0);
  }

  void _animateValues() {
    List<double> thisWeekValues = _lerpList(
        _stateBeforeAnimation.thisWeekValues, _stateAfterAnimation.thisWeekValues, _animationController.value);
    List<double> lastWeekValues = _lerpList(
        _stateBeforeAnimation.lastWeekValues, _stateAfterAnimation.lastWeekValues, _animationController.value);
    double maxValue =
        lerpDouble(_stateBeforeAnimation.maxValue, _stateAfterAnimation.maxValue, _animationController.value);
    int thisWeekCheckinsCount = lerpDouble(_stateBeforeAnimation.thisWeekCheckinsCount,
            _stateAfterAnimation.thisWeekCheckinsCount, _animationController.value)
        .floor();
    int lastWeekCheckinsCount = lerpDouble(_stateBeforeAnimation.lastWeekCheckinsCount,
            _stateAfterAnimation.lastWeekCheckinsCount, _animationController.value)
        .floor();
    _updateState(state.copyWith(
      thisWeekValues: thisWeekValues,
      lastWeekValues: lastWeekValues,
      maxValue: maxValue,
      thisWeekCheckinsCount: thisWeekCheckinsCount,
      lastWeekCheckinsCount: lastWeekCheckinsCount,
    ));
  }

  List<double> _lerpList(List<double> a, List<double> b, double t) =>
      List.generate(a.length, (index) => lerpDouble(a[index], b[index], t));

  num _getListMaxValue(List<num> list) => list.cast<num>().reduce(max);

  void _updateState(WeeklyCheckinsInsightsState newState) {
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
class WeeklyCheckinsInsightsState {
  final List<double> lastWeekValues;
  final List<double> thisWeekValues;
  final double maxValue;
  final int thisWeekCheckinsCount;
  final int lastWeekCheckinsCount;

  WeeklyCheckinsInsightsState({
    this.lastWeekValues,
    this.thisWeekValues,
    this.maxValue,
    this.thisWeekCheckinsCount,
    this.lastWeekCheckinsCount,
  });

  WeeklyCheckinsInsightsState copyWith({
    List<double> lastWeekValues,
    List<double> thisWeekValues,
    double maxValue,
    int thisWeekCheckinsCount,
    int lastWeekCheckinsCount,
  }) =>
      WeeklyCheckinsInsightsState(
        lastWeekValues: lastWeekValues ?? this.lastWeekValues,
        thisWeekValues: thisWeekValues ?? this.thisWeekValues,
        maxValue: maxValue ?? this.maxValue,
        thisWeekCheckinsCount: thisWeekCheckinsCount ?? this.thisWeekCheckinsCount,
        lastWeekCheckinsCount: lastWeekCheckinsCount ?? this.lastWeekCheckinsCount,
      );
}
