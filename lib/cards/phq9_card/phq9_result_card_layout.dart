import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/cards/basic_card.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/cards_page/cards_page.dart';
import 'package:aebeze/cards/phq9_card/phq9_result_card_presenter.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/progress_bar.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PHQ9ResultCardLayout extends BasicCardLayout {
  static final String content = "content";
  final ValueGetter<int> scoreGetter;

  PHQ9ResultCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded, this.scoreGetter)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    _layoutContent(context, size, layoutChild, positionChild);
  }

  void _layoutContent(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutChild(content, BoxConstraints.tight(size));
    positionChild(content, Offset.zero);
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addContent(list);
    return list;
  }

  void addContent(LayoutList list) {
    list.layout(content, () => _CardContent(pageContext, scoreGetter));
  }
}

class _CardContent extends StatefulWidget {
  static const int maxScore = 30;
  final PageContext pageContext;
  final ValueGetter<int> scoreGetter;

  _CardContent(
    this.pageContext,
    this.scoreGetter,
  );

  @override
  _CardContentState createState() => _CardContentState();
}

class _CardContentState extends BasePresenter<_CardContent> implements PHQ9ResultCardPresenterView {
  PHQ9ResultCardPresenter presenter;
  TapGestureRecognizer textPressRecognizer;

  int get score => widget.scoreGetter();

  _CardContentState() {
    presenter = PHQ9ResultCardPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    widget.pageContext.visibilityChangedNotifier?.addListener(onVisibilityChanged);
    textPressRecognizer = TapGestureRecognizer()..onTap = () => presenter.openSMSApp();
  }

  @override
  void dispose() {
    widget.pageContext.visibilityChangedNotifier?.removeListener(onVisibilityChanged);
    textPressRecognizer?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageContext.visibilityChangedNotifier?.removeListener(onVisibilityChanged);
    widget.pageContext.visibilityChangedNotifier?.addListener(onVisibilityChanged);
  }

  void onVisibilityChanged() {
    if (widget.pageContext.visibilityChangedNotifier?.value == CardVisibilityChanged.onScreen) {
      refreshState();
    }
  }

  void onDoneButtonPressed() {
    presenter.trackCompletion(score > 2);
    widget.pageContext.onNextPressed();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 100.0 + MediaQuery.of(context).padding.bottom,
              left: defaultPadding,
              right: defaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(),
                  _Title(),
                  _ScoreIndicator(score),
                  _MainText(score, textPressRecognizer),
                ],
              ),
            ),
            _DoneButton(onDoneButtonPressed),
          ],
        ),
      );
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: TextScaled(
          localize(context, "phq9_result_title_header").toUpperCase(),
          style: AppTextStyles.subhead,
        ),
      );
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: TextScaled(
          localize(context, "phq9_result_title"),
          style: AppTextStyles.h2,
        ),
      );
}

class _ScoreIndicator extends StatelessWidget {
  static const double strokeWidth = 8.0;
  final int score;

  _ScoreIndicator(this.score);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: ProgressBar(
          length: MediaQuery.of(context).size.width - 40.0 - strokeWidth,
          position: score / _CardContent.maxScore,
          color: score < 6 ? AppColors.iceBlue : score < 16 ? const Color(0xFFFFCA00) : Color(0xFFDD0707),
          width: strokeWidth,
          backgroundColor: Colors.black.withOpacity(0.1),
          strokeCap: StrokeCap.round,
        ),
      );
}

class _MainText extends StatelessWidget {
  final int score;
  final TapGestureRecognizer textPressRecognizer;

  _MainText(this.score, this.textPressRecognizer);

  // On small screen the text is too big.
  double getTextScale(BuildContext context) => MediaQuery.of(context).size.width < defaultScreenWidth
      ? 1.0
      : MediaQuery.textScaleFactorOf(context).clamp(0.0, maxTextScaleFactor);

  TextSpan getText(BuildContext context) {
    String text1;
    String text2;
    if (score < 6) {
      text1 = localize(context, "phq9_result_low_start");
      text2 = localize(context, "phq9_result_low_end");
    } else if (score < 16) {
      text1 = localize(context, "phq9_result_medium_start");
      text2 = localize(context, "phq9_result_medium_end");
    } else {
      text1 = localize(context, "phq9_result_high_start");
      text2 = localize(context, "phq9_result_high_end");
    }
    return TextSpan(
      text: text1,
      style: AppTextStyles.bodyReg,
      children: <TextSpan>[
        TextSpan(
          text: localize(context, "phq9_result_sms_home_to"),
          style: AppTextStyles.bodyReg.copyWith(color: AppColors.tealish),
          recognizer: textPressRecognizer,
        ),
        TextSpan(
          text: text2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => RichText(
        text: getText(context),
        textScaleFactor: getTextScale(context),
      );
}

class _DoneButton extends StatelessWidget {
  final VoidCallback onPressed;

  _DoneButton(this.onPressed);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.only(
              left: 10.0,
              right: defaultPadding,
              bottom: 31.0 + MediaQuery.of(context).padding.bottom,
            ),
            color: Colors.transparent,
            child: TextScaled(
              localize(context, "button_done").toUpperCase(),
              style: AppTextStyles.instruction,
            ),
          ),
        ),
      );
}
