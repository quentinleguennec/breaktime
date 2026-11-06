import 'dart:ui';

import 'package:aebeze/assets.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardInstructionButton extends StatelessWidget {
  final String text;
  final bool isIconOnTheRight;
  final VoidCallback onPressed;

  const CardInstructionButton({
    @required this.text,
    this.isIconOnTheRight = false,
    this.onPressed,
  });

  Widget get image => Image(
        width: 12,
        height: 16,
        color: Colors.white,
        image: AssetImage(Assets.pillcastPlayButton),
      );

  Widget get textWidget => TextScaled(
        text,
        style: AppTextStyles.h6ZirkonRegular.copyWith(color: Colors.white),
      );

  Widget get space => Padding(padding: const EdgeInsets.only(left: 12));

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(74),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isIconOnTheRight) ...[
                    textWidget,
                    space,
                    image,
                  ],
                  if (!isIconOnTheRight) ...[
                    image,
                    space,
                    textWidget,
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}
