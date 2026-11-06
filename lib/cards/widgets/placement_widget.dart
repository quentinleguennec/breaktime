import 'package:aebeze/app_constants.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/column_separator.dart';
import 'package:aebeze/widgets/reveal_container.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlacementWidget extends StatelessWidget {
  final String type;
  final String content;
  final String header;
  final String textColor;
  final Background background;
  final Animation<double> animation;

  PlacementWidget({
    @required this.type,
    @required this.content,
    @required this.header,
    @required this.textColor,
    @required this.background,
    this.animation,
  });

  PlacementWidget.fromCard(DataCard card, {this.animation})
      : type = card.placement?.type,
        content = card.placement?.content,
        header = card.placement?.header,
        textColor = card.placement?.textColor,
        background = card.placement?.background;

  @override
  Widget build(BuildContext context) => Visibility(
        visible: content != null || header != null,
        child: wrapInAnimation(
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (type == "bottom") Expanded(child: Container()),
              if (type != "bottom") Padding(padding: const EdgeInsets.only(top: 126)),
              _Placement(
                content: content,
                header: header,
                textColor: textColor,
                background: background,
              ),
              if (type == "bottom") Padding(padding: const EdgeInsets.only(bottom: 176))
            ],
          ),
        ),
      );

  Widget wrapInAnimation(Widget child) => animation != null ? RevealContainer(animation, child: child) : child;
}

class _Placement extends StatelessWidget {
  final String content;
  final String header;
  final String textColor;
  final Background background;

  _Placement({
    @required this.content,
    @required this.header,
    @required this.textColor,
    @required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.15),
        color: stringToColor(background?.color),
        child: Padding(
          padding: const EdgeInsets.only(left: hugePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (header != null)
                TextScaled(
                  header.toUpperCase(),
                  style: AppTextStyles.h6ZirkonRegular.copyWith(color: stringToColor(textColor)),
                ),
              if (header != null && content != null) ColumnSeparator.medium,
              if (content != null)
                TextScaled(
                  content,
                  style: AppTextStyles.bigTitle.copyWith(color: stringToColor(textColor)),
                  textScaleFactor: 1,
                ),
            ],
          ),
        ),
      );
}
