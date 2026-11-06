import 'dart:async';
import 'dart:ui';

import 'package:aebeze/bloc_pattern/bloc.dart';
import 'package:aebeze/bloc_pattern/bloc_single_ticker_provider_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FactorsInsightsBloc extends Bloc with BlocSingleTickerProviderStateMixin {
  final _streamController = StreamController<FactorsInsightsState>();

  FactorsInsightsState _state;
  AnimationController _animationController;
  FactorsInsightsState _stateBeforeAnimation;
  FactorsInsightsState _stateAfterAnimation;

  FactorsInsightsBloc() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(_animateValues);

    _state = FactorsInsightsState.empty();

    _streamController.sink.add(_state);
  }

  FactorsInsightsState get state => _state;

  Stream<FactorsInsightsState> get stream => _streamController.stream;

  void startAnimation({
    @required List<FactorData> newFactors,
  }) {
    _stateBeforeAnimation = FactorsInsightsState(factors: state.factors);

    int maxCount = 0;
    if (newFactors != null && newFactors.isNotEmpty) {
      /// List needs to be ordered. See [FactorsInsightsState].
      newFactors.sort((e1, e2) => e1.count <= e2.count ? 1 : -1);
      maxCount = newFactors.first.count;
    }

    List<FactorData> factors = List.generate(
      newFactors.length,
      (index) => FactorData(
        factor: newFactors[index].factor,
        count: newFactors[index].count,
        barFillRatio: newFactors[index].count / maxCount,
      ),
    );

    _stateAfterAnimation = FactorsInsightsState(
      factors: factors,
    );

    _animationController.forward(from: 0);
  }

  void _animateValues() {
    List<FactorData> newFactors = List<FactorData>(_stateAfterAnimation.factors.length);

    for (int i = 0; i < _stateAfterAnimation.factors.length; i++) {
      FactorData stateBeforeAnimationFactor;
      if (i < _stateBeforeAnimation.factors.length) {
        stateBeforeAnimationFactor = _stateBeforeAnimation.factors[i];
      } else {
        stateBeforeAnimationFactor = FactorData.base();
      }
      newFactors[i] = FactorData(
        factor: _stateAfterAnimation.factors[i].factor,
        count: lerpDouble(
          stateBeforeAnimationFactor.count,
          _stateAfterAnimation.factors[i].count,
          _animationController.value,
        ).floor(),
        barFillRatio: lerpDouble(
          stateBeforeAnimationFactor.barFillRatio,
          _stateAfterAnimation.factors[i].barFillRatio,
          _animationController.value,
        ),
      );
    }

    _updateState(state.copyWith(factors: newFactors));
  }

  void _updateState(FactorsInsightsState newState) {
    if (newState == _state) return;

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
class FactorsInsightsState {
  /// The factors should be ordered from the one with the highest count to the one with the lowest count.
  final List<FactorData> factors;

  FactorsInsightsState({
    this.factors,
  });

  bool get isEmpty => !factors.any((factor) => factor != FactorData.base());

  factory FactorsInsightsState.empty() => FactorsInsightsState(
        factors: List.generate(3, (_) => FactorData.base()),
      );

  FactorsInsightsState copyWith({
    List<FactorData> factors,
  }) =>
      FactorsInsightsState(
        factors: factors ?? this.factors,
      );
}

@immutable
class FactorData {
  final String factor;
  final int count;
  final double barFillRatio;

  const FactorData({
    @required this.factor,
    @required this.count,
    this.barFillRatio,
  });

  factory FactorData.base() => FactorData(factor: "", count: 0, barFillRatio: 0.5);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactorData &&
          runtimeType == other.runtimeType &&
          factor == other.factor &&
          count == other.count &&
          barFillRatio == other.barFillRatio;

  @override
  int get hashCode => factor.hashCode ^ count.hashCode ^ barFillRatio.hashCode;
}
