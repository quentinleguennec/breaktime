import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/widgets/progress_bar.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardTimer extends StatefulWidget {
  final PageContext pageContext;

  CardTimer(this.pageContext);

  @override
  _TreatmentTimerState createState() => _TreatmentTimerState();
}

class _TreatmentTimerState extends SafeState<CardTimer> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> timerAnimation;

  CardTimerController get controller => widget.pageContext.cardTimerController;

  @override
  void initState() {
    controller?.addListener(onControllerUpdated);

    animationController = AnimationController(vsync: this, duration: widget.pageContext.card.duration);
    controller._duration = widget.pageContext.card.duration;
    timerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    animationController.addListener(() {
      controller._elapsedTime = animationController.duration * animationController.value;
    });
    animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        refreshState();
        controller._complete();
        widget.pageContext.onCardCompleted();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller?.removeListener(onControllerUpdated);
    animationController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CardTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.cardTimerController?.removeListener(onControllerUpdated);
    controller?.addListener(onControllerUpdated);
  }

  void onControllerUpdated() {
    if (animationController.duration != widget.pageContext.card.duration) {
      animationController.duration = widget.pageContext.card.duration;
    }
    switch (controller._action) {
      case TimerAction.pause:
        animationController.stop();
        break;
      case TimerAction.reset:
        animationController.reset();
        break;
      case TimerAction.resume:
        animationController.forward();
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: hugePadding),
        width: MediaQuery.of(context).size.width - hugePadding * 2,
        child: AnimatedProgressBar(
          animation: timerAnimation,
          length: MediaQuery.of(context).size.width - hugePadding * 2,
          width: 1,
          color: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
      );
}

enum TimerAction { pause, reset, resume }

enum TimerStatus { dismissed, paused, playing, completed }

class CardTimerController extends ChangeNotifier {
  TimerAction _action;
  TimerStatus _status = TimerStatus.dismissed;
  Duration _elapsedTime;
  Duration _duration;

  TimerStatus get status => _status;

  Duration get elapsedTime => _elapsedTime ?? Duration.zero;

  Duration get duration => _duration ?? Duration.zero;

  double get elapsedRatio =>
      _elapsedTime == null || _duration == null ? 0.0 : _elapsedTime.inMilliseconds / _duration.inMilliseconds;

  void pause() {
    if (_action == TimerAction.pause) return;
    if (_status == TimerStatus.completed || _status == TimerStatus.dismissed) return;
    _action = TimerAction.pause;
    _status = TimerStatus.paused;
    notifyListeners();
  }

  void reset() {
    if (_action == TimerAction.reset) return;
    _action = TimerAction.reset;
    _status = TimerStatus.dismissed;
    notifyListeners();
  }

  void resume() {
    if (_action == TimerAction.resume) return;
    if (_status == TimerStatus.completed) return;
    _action = TimerAction.resume;
    _status = TimerStatus.playing;
    notifyListeners();
  }

  void _complete() {
    if (_status == TimerStatus.completed) return;
    _status = TimerStatus.completed;
    notifyListeners();
  }
}
