import 'package:aebeze/widgets/animated_reveal_transition.dart';
import 'package:aebeze/widgets/text_input_field.dart';
import 'package:flutter/widgets.dart';

class MoodSelectorInputField extends AnimatedWidget {
  static const Duration cascadeDuration = const Duration(milliseconds: 100);
  static const Duration cascadeDelay = const Duration(milliseconds: 50);

  final Animation cascadingRevealAnimation;
  final Function onChange;
  final TextStyle style;

  MoodSelectorInputField({
    @required this.cascadingRevealAnimation,
    @required this.onChange,
    this.style,
  }) : super(listenable: cascadingRevealAnimation);

  @override
  Widget build(BuildContext context) => AnimatedRevealTransitionWidget(
        animation: cascadingRevealAnimation,
        translationValue: 0.0,
        child: TextInputField(
          style: style,
          hint: 'Other',
          isTransparent: true,
          onChanged: onChange,
        ),
      );
}
