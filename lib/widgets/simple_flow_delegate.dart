import 'package:flutter/widgets.dart';

wrapInFlow(child) => Flow.unwrapped(delegate: SimpleFlowDelegate(), children: <Widget>[child]);

class SimpleFlowDelegate extends FlowDelegate {
  SimpleFlowDelegate();

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; ++i) {
      context.paintChild(i);
    }
  }

  @override
  bool shouldRepaint(SimpleFlowDelegate oldDelegate) => false;
}
