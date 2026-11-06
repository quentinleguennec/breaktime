import 'package:aebeze/app_constants.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/cards/basic_card_layout.dart';
import 'package:aebeze/cards/upsell_card_presenter.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/multi_child_layout.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';

class UpsellCardLayout extends BasicCardLayout {
  static final String button = "button";

  UpsellCardLayout(pageContext, animator, onVideoLoaded, onImageLoaded)
      : super(pageContext, animator, onVideoLoaded, onImageLoaded);

  @override
  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    layoutBackgroundImage(context, layoutChild, size, positionChild);
    layoutBackgroundVideo(context, size, layoutChild, positionChild);
    layoutPlacements(context, size, layoutChild, positionChild);
    _layoutButton(context, size, layoutChild, positionChild);
    layoutTimer(context, size, layoutChild, positionChild);
    layoutActiveIngredientIcon(context, size, layoutChild, positionChild);
    layoutNextArrow(context, size, layoutChild, positionChild);
  }

  void _layoutButton(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild) {
    Size buttonSize = layoutChild(button, BoxConstraints.tightFor());
    positionChild(
      button,
      Offset(
        (size.width - buttonSize.width) * 0.5,
        size.height - buttonSize.height - 78.0 - MediaQuery.of(context).padding.bottom,
      ),
    );
  }

  @override
  LayoutList children(BuildContext context) {
    LayoutList list = LayoutList();
    addBackgroundImage(list);
    addBackgroundVideo(list);
    addPlacements(list);
    addButton(list);
    addTimer(list);
    addActiveIngredientIcon(list);
    addNextButton(list);
    return list;
  }

  void addButton(LayoutList list) {
    list.layout(button, () => _Button(card));
  }
}

class _Button extends StatefulWidget {
  final DataCard card;

  _Button(this.card);

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends BasePresenter<_Button> implements UpsellCardPresenterView {
  bool isHeld = false;
  UpsellCardPresenter presenter;

  @override
  void initState() {
    super.initState();
    presenter = UpsellCardPresenter(this);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setMountedState(() => isHeld = true),
        onTapCancel: () => setMountedState(() => isHeld = false),
        onTap: () {
          /// Add some time for the tap feedback to show.
          Future.delayed(const Duration(milliseconds: 100), () => setMountedState(() => isHeld = false));
          presenter.openLink(widget.card);
        },
        child: Container(
          height: 44.0,
          padding: const EdgeInsets.only(left: 12.0, right: 16.0),
          decoration: BoxDecoration(
            color: isHeld ? const Color(0xFFFF9090) : const Color(0xFFEF5A5A),
            borderRadius: const BorderRadius.all(const Radius.circular(22.0)),
          ),
          child: Row(
            children: <Widget>[
              Image.asset(Assets.iconGlobe, width: defaultPadding, height: defaultPadding),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextScaled(
                  widget.card.upsellData.text.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                  maxLines: 1,
                ),
              )
            ],
          ),
        ),
      );
}
