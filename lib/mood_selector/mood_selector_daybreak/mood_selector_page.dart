import 'package:aebeze/app.dart';
import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/mood_selector/mood_selector_daybreak/drag_circle.dart';
import 'package:aebeze/mood_selector/mood_selector_daybreak/mood_selector_presenter.dart';
import 'package:aebeze/mood_selector/navigation_buttons.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/text_utils.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/custom_app_bars.dart';
import 'package:aebeze/widgets/separator_line.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoodSelector extends StatefulWidget {
  final ValueChanged<Mood> onMoodUpdated;
  final VoidCallback onNextButtonPressed;
  final VoidCallback onCancelButtonPressed;
  final ValueChanged<double> onCircleMoved;

  MoodSelector({
    this.onMoodUpdated,
    this.onNextButtonPressed,
    this.onCancelButtonPressed,
    this.onCircleMoved,
  });

  @override
  _MoodSelectorState createState() => _MoodSelectorState();
}

class _MoodSelectorState extends BasePresenter<MoodSelector>
    with TickerProviderStateMixin
    implements MoodSelectorPresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Mood> moods = Moods().moods;

  MoodSelectorPresenter presenter;
  double mood = 0;
  int focusedMoodIndex = Moods.count ~/ 2;

  Mood get focusedMood => moods[focusedMoodIndex];

  int get focusedMoodValue => (Moods.count ~/ 2) - focusedMoodIndex;

  double get backgroundGradientHeight => MediaQuery.of(context).size.height * 2;

  Color get textColor => focusedMood.value > -3 ? Colors.black : Colors.white;

  _MoodSelectorState() {
    presenter = MoodSelectorPresenter(this);
  }

  void onDragCircleTouched() => HapticFeedback.mediumImpact();

  void onDragCircleMoved(PositionChangedData data) {
    double maxDragCircleOffsetValue =
        (1 - DragCircle.indicatorsVerticalPaddingHeightRatio) * MediaQuery.of(context).size.height * 0.5 -
            DragCircle.indicatorsContainerSize * 0.5;
    mood = -data.circleOffset.dy / maxDragCircleOffsetValue;
    focusedMoodIndex = data.focusedPointIndex;
    refreshState();
    widget.onCircleMoved(mood);
    widget.onMoodUpdated?.call(focusedMood);
  }

  void onCaptureButtonPressed() => widget.onNextButtonPressed?.call();

  Widget get moodText => IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextScaled(
              localize(context, "mood_selector_daybreak_how_do_you_feel"),
              style: AppTextStyles.h3SmallProtoGroteskLight.copyWith(color: Colors.white),
            ),
            ColumnSeparator.small,
            Row(
              children: <Widget>[
                Container(
                  width: 25,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, -focusedMoodValue.toDouble()),
                      child: TextScaled(
                        getNumberAsSignedString(focusedMoodValue),
                        style: AppTextStyles.smallText,
                      ),
                    ),
                  ),
                ),
                TextScaled(
                  moods[focusedMoodIndex].text,
                  style: AppTextStyles.h3SmallProtoGroteskLight.copyWith(color: Colors.white),
                ),
              ],
            ),
            ColumnSeparator.small,
            SeparatorLine(),
          ],
        ),
      );

  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            DragCircle(
              startingPointIndex: Moods.count ~/ 2,
              onPositionChanged: onDragCircleMoved,
              onTouched: onDragCircleTouched,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                NavigationAppBarOverlay(
                  onPressed: widget.onCancelButtonPressed,
                  withInvertedColor: !App.isDayBreak,
                ),
                ColumnSeparator.veryBig,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: moodText,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavigationButton(
                text: localize(context, "button_next"),
                onTap: onCaptureButtonPressed,
              ),
            ),
          ],
        ),
      );
}
