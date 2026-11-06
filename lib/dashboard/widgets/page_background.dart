import 'package:aebeze/app.dart';
import 'package:aebeze/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DashboardPageBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) => !App.isDayBreak
      ? Container(color: Colors.white)
      : Image.asset(
          Assets.backgroundDefaultDaybreak,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
        );
}
