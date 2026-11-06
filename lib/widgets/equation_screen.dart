import 'package:aebeze/app_constants.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EquationScreen extends StatefulWidget {
  final AnimationController animationController;

  EquationScreen(this.animationController);

  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<EquationScreen> with SingleTickerProviderStateMixin {
  Animation<double> firstLineAnimation;
  Animation<double> secondLineAnimation;
  List<Animation<double>> animationList = List();
  List<String> ingredients = [
    "OXYTOCIN",
    "DOPAMINE",
    "EXPERIMENTAL MEDICINE",
    "GABA",
    "SEROTONIN",
    "OXYTOCIN",
    "SEROTONIN",
    "DOPAMINE",
    "EXPERIMENTAL MEDICINE",
    "SEROTONIN"
  ];

  @override
  void initState() {
    widget.animationController.duration = Duration(seconds: 2);
    widget.animationController.addListener(() => refreshState());

    firstLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.0,
          0.4,
          curve: Curves.linear,
        ),
      ),
    );
    secondLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.05,
          0.45,
          curve: Curves.linear,
        ),
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    widget.animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 100.0, left: defaultPadding, right: defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xfffddb92),
                const Color(0xffd1fdff),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: firstLineAnimation.value,
                child: Text(
                  "A DOSE OF",
                  style: AppTextStyles.bodyReg,
                ),
              ),
              Opacity(
                opacity: secondLineAnimation.value,
                child: Text(
                  "Happiness",
                  style: AppTextStyles.h1,
                ),
              ),
              Opacity(
                opacity: secondLineAnimation.value,
                child: Padding(
                  padding: EdgeInsets.only(top: 40, bottom: 26),
                  child: Container(
                    color: Colors.black,
                    width: 46,
                    height: 1,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemExtent: 40,
                itemCount: 10,
                itemBuilder: (context, index) => buildItem(index),
              ),
            ],
          ),
        ),
      );

  Widget buildItem(int index) {
    var animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          0.04 * index + 0.1,
          0.04 * index + 0.5,
          curve: Curves.linear,
        ),
      ),
    );
    animationList.add(animation);
    return Opacity(
      opacity: animation.value,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (index + 1).toString(),
            style: AppTextStyles.instruction,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index == 9 ? 24 : 32),
              child: Text(
                ingredients[index],
                textAlign: TextAlign.left,
                style: AppTextStyles.medicinal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
