import 'package:aebeze/app_constants.dart';
import 'package:aebeze/cards/widgets/drag_container.dart';
import 'package:aebeze/cards/widgets/placement_widget.dart';
import 'package:aebeze/cards/widgets/zoom_in_out_container.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/utils/colors_utils.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DragCardContent extends StatefulWidget {
  final DataCard card;

  DragCardContent(this.card);

  @override
  _DragCardState createState() => _DragCardState();
}

enum DragCardMode { dragging, full_screen }

class _DragCardState extends SafeState<DragCardContent> {
  static const double cardWidthRatio = 0.5;
  static const double cardHeightRatio = 0.4;
  DragCardMode mode;

  @override
  void initState() {
    mode = DragCardMode.dragging;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => mode == DragCardMode.dragging
      ? DragContainer(buildSmallCardContent, changeMode, cardWidthRatio, cardHeightRatio)
      : ZoomInOutContainer(
          buildLargeCardBackground, buildLargeCardContent, changeMode, cardWidthRatio, cardHeightRatio);

  Widget buildSmallCardContent() => Container(
        padding: const EdgeInsets.all(defaultPadding),
        color: cardBackgroundColor(widget.card),
        child: TextScaled(
          widget.card.description,
          style: AppTextStyles.h2.copyWith(color: cardOpposingColor(widget.card.background)),
        ),
      );

  Widget buildLargeCardBackground() => Container(color: cardBackgroundColor(widget.card));

  Widget buildLargeCardContent() => Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: PlacementWidget.fromCard(widget.card),
      );

  void changeMode() =>
      setMountedState(() => mode = mode == DragCardMode.full_screen ? DragCardMode.dragging : DragCardMode.full_screen);
}
