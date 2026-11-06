import 'package:flutter/widgets.dart';

class CardOverlayMenuController extends ChangeNotifier {
  bool _isHidden = false;

  bool get isHidden => _isHidden;

  CardOverlayMenuController({bool startsHidden = true}) {
    _isHidden = startsHidden;
    notifyListeners();
  }

  void show({bool force = false}) {
    if (!force && !_isHidden) return;
    _isHidden = false;
    notifyListeners();
  }

  void hide({bool force = false}) {
    if (!force && _isHidden) return;
    _isHidden = true;
    notifyListeners();
  }

  void toggleVisibility() => isHidden ? show() : hide();
}
