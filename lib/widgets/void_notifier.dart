import 'package:flutter/widgets.dart';

/// A [ChangeNotifier] that doesn't hold a value.
///
/// Because calling [notifyListeners] on a [ChangeNotifier] causes a warning.
class VoidNotifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
