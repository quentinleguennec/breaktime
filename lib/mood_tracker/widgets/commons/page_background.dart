import 'package:aebeze/app.dart';
import 'package:aebeze/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InsightsPageBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Image.asset(
        App.isDayBreak ? Assets.backgroundDefaultDaybreak : Assets.backgroundInsightsMoodrise,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fill,
      );
}
