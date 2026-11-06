import 'package:flutter/widgets.dart';

abstract class SafeState<T extends StatefulWidget> extends State<T> {
  void setMountedState(VoidCallback execute) {
    if (mounted) setState(() => execute());
  }

  void refreshState() {
    if (mounted) setState(() {});
  }
}
