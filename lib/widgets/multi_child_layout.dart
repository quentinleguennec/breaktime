import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

abstract class MultiChildLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomMultiChildLayout(
        delegate: ChildLayoutAdapter(
            (size, layoutChild, positionChild) => performLayout(context, size, layoutChild, positionChild)),
        children: children(context),
      );

  LayoutList children(BuildContext context);

  void performLayout(BuildContext context, Size size, LayoutChild layoutChild, PositionChild positionChild);
}

typedef Size LayoutChild(Object childId, BoxConstraints constraints);

typedef void PositionChild(Object childId, Offset offset);

typedef void PerformLayout(Size size, LayoutChild layoutChild, PositionChild positionChild);

class ChildLayoutAdapter extends MultiChildLayoutDelegate {
  final PerformLayout layout;
  final bool shouldAlwaysRelayout;

  ChildLayoutAdapter(this.layout, {this.shouldAlwaysRelayout = false});

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => shouldAlwaysRelayout;

  @override
  void performLayout(Size size) => layout(size, layoutChild, positionChild);
}

class LayoutList extends DelegatingList<Widget> {
  final List<Widget> _list;

  LayoutList() : this._(<Widget>[]);

  LayoutList._(list)
      : _list = list,
        super(list);

  void layout(String id, ValueGetter<Widget> buildWidget, {bool when = true}) =>
      when ? _list.add(LayoutId(id: id, child: buildWidget())) : {};
}
