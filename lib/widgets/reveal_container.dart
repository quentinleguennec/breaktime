import 'package:flutter/widgets.dart';

class RevealContainer extends AnimatedWidget {
  final Animation<double> animation;
  final Widget child;
  final ValueGetter<Widget> builder;

  RevealContainer(this.animation, {this.child, this.builder}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: animation.value,
        child: (animation.value > 0.0) ? (child != null ? child : builder()) : Container(),
      );
}
