import 'package:aebeze/widgets/shadow_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ZoomAnimator {
  AnimationController animator;
  Animation<double> verticalAnimation;
  Animation<double> horizontalAnimation;
  Animation<double> opacityAnimation;

  ZoomAnimator(widthRatio, heightRatio, TickerProviderStateMixin vsync) {
    animator = AnimationController(vsync: vsync, duration: Duration(milliseconds: 250));
    verticalAnimation = Tween<double>(begin: heightRatio, end: 1.0).animate(
      CurvedAnimation(
        parent: animator,
        curve: Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );
    horizontalAnimation = Tween<double>(begin: widthRatio, end: 1.0).animate(
      CurvedAnimation(
        parent: animator,
        curve: Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animator,
        curve: Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  get mergedAnimations => Listenable.merge([verticalAnimation, horizontalAnimation]);

  void reverse() => animator.reverse();

  void forward() => animator.forward();

  void reset() => animator.reset();

  void dispose() => animator?.dispose();

  void addDismissedListener(Function listener) => animator.addListener(() {
        if (animator.status == AnimationStatus.dismissed) {
          listener();
        }
      });
}

class ZoomInOutContainer extends StatefulWidget {
  final ValueGetter<Widget> childBuilder;
  final ValueGetter<Widget> backgroundBuilder;
  final VoidCallback onTap;
  final double cardHeightRatio;
  final double cardWidthRatio;

  ZoomInOutContainer(this.backgroundBuilder, this.childBuilder, this.onTap, this.cardWidthRatio, this.cardHeightRatio)
      : super(key: UniqueKey());

  @override
  _ZoomOutInContainerState createState() => _ZoomOutInContainerState();
}

class _ZoomOutInContainerState extends State<ZoomInOutContainer> with TickerProviderStateMixin {
  ZoomAnimator animator;

  @override
  void initState() {
    animator = ZoomAnimator(widget.cardWidthRatio, widget.cardHeightRatio, this);
    animator.forward();
    super.initState();
  }

  @override
  void dispose() {
    animator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _zoomOut();
      },
      child: _ZoomAnimatedContainer(
        widget.backgroundBuilder,
        widget.childBuilder,
        animator,
      ));

  void _zoomOut() => animator
    ..addDismissedListener(() => widget.onTap())
    ..reverse();
}

class _ZoomAnimatedContainer extends AnimatedWidget {
  final ValueGetter<Widget> backgroundBuilder;
  final ValueGetter<Widget> childBuilder;
  final ZoomAnimator animator;

  _ZoomAnimatedContainer(this.backgroundBuilder, this.childBuilder, this.animator)
      : super(listenable: animator.mergedAnimations);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, size) {
        final double vs = (size.maxHeight - size.maxHeight * animator.verticalAnimation.value) / 2;
        final double hs = (size.maxWidth - size.maxWidth * animator.horizontalAnimation.value) / 2;
        return Container(
          margin: EdgeInsets.only(top: vs, bottom: vs, left: hs, right: hs),
          child: ShadowContainer(
              child: Stack(
            children: buildChildren(),
          )),
        );
      });

  List<Widget> buildChildren() {
    List<Widget> list = List<Widget>();
    list.add(backgroundBuilder());
    if (animator.horizontalAnimation.value == 1.0)
      list.add(Opacity(opacity: animator.opacityAnimation.value, child: childBuilder()));
    return list;
  }
}
