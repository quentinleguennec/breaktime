import 'package:aebeze/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CountText extends StatelessWidget {
  final int count;
  final String text;

  const CountText({
    @required this.count,
    @required this.text,
  });

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          text: "$count",
          style: AppTextStyles.h5ZirkonRegular.copyWith(color: Colors.white),
          children: <TextSpan>[
            TextSpan(
              text: "  $text",
              style: AppTextStyles.h6ZirkonRegular.copyWith(color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      );
}
