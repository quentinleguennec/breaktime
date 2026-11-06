import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const PageScrollPhysics _kPagePhysics = const PageScrollPhysics();
final PageController _defaultPageController = PageController();

/// Custom extension of the [PageView]
///
/// Modified to have access to the [cacheExtent] property of the [Scrollable] to
/// display pages left and right of the current page.
///
/// Modified when [onPageChanged] is called. Instead of calling it when half the page is scrolled it's called when
/// the page is fully scrolled. This hide potential stutter when doing heavy computation in the callback.
///
/// Added [onScrollStarted] and [onScrollEnded]
class CustomPageView extends StatefulWidget {
  /// Creates a scrollable list that works page by page from an explicit [List]
  /// of widgets.
  ///
  /// This constructor is appropriate for page views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the page view, instead of just
  /// those children that are actually visible.
  CustomPageView({
    Key key,
    this.scrollDirection: Axis.horizontal,
    this.reverse: false,
    PageController controller,
    this.physics,
    this.cacheExtent = 0.0,
    this.pageSnapping: true,
    this.onPageChanged,
    this.onScrollStarted,
    this.onScrollEnded,
    List<Widget> children: const <Widget>[],
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate = SliverChildListDelegate(children),
        super(key: key);

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [CustomPageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  CustomPageView.builder({
    Key key,
    this.scrollDirection: Axis.horizontal,
    this.reverse: false,
    PageController controller,
    this.physics,
    this.cacheExtent = 0.0,
    this.pageSnapping: true,
    this.onPageChanged,
    this.onScrollStarted,
    this.onScrollEnded,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate = SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key);

  /// Creates a scrollable list that works page by page with a custom child
  /// model.
  CustomPageView.custom({
    Key key,
    this.scrollDirection: Axis.horizontal,
    this.reverse: false,
    PageController controller,
    this.physics,
    this.cacheExtent = 0.0,
    this.pageSnapping: true,
    this.onPageChanged,
    this.onScrollStarted,
    this.onScrollEnded,
    @required this.childrenDelegate,
  })  : assert(childrenDelegate != null),
        controller = controller ?? _defaultPageController,
        super(key: key);

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  final PageController controller;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// The viewport has an area before and after the visible area to cache items
  /// that are about to become visible when the user scrolls.
  ///
  /// Items that fall in this cache area are laid out even though they are not
  /// (yet) visible on screen. The [cacheExtent] describes how many pixels
  /// the cache area extends before the leading edge and after the trailing edge
  /// of the viewport.
  ///
  /// The total extent, which the viewport will try to cover with children, is
  /// [cacheExtent] before the leading edge + extent of the main axis +
  /// [cacheExtent] after the trailing edge.
  ///
  /// The cache area is also used to implement implicit accessibility scrolling
  /// on iOS: When the accessibility focus moves from an item in the visible
  /// viewport to an invisible item in the cache area, the framework will bring
  /// that item into view with an (implicit) scroll action.
  final double cacheExtent;

  /// Called whenever the page in the center of the viewport changes.
  ///
  /// Returns the index of the page.
  final ValueChanged<int> onPageChanged;

  /// Called when the user starts scrolling.
  final VoidCallback onScrollStarted;

  /// Called when the user stops scrolling.
  final VoidCallback onScrollEnded;

  /// A delegate that provides the children for the [CustomPageView].
  ///
  /// The [CustomPageView.custom] constructor lets you specify this delegate
  /// explicitly. The [CustomPageView] and [CustomPageView.builder] constructors create a
  /// [childrenDelegate] that wraps the given [List] and [IndexedWidgetBuilder],
  /// respectively.
  final SliverChildDelegate childrenDelegate;

  @override
  _CustomPageViewState createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection = textDirectionToAxisDirection(textDirection);
        return widget.reverse ? flipAxisDirection(axisDirection) : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics = widget.pageSnapping ? _kPagePhysics.applyTo(widget.physics) : widget.physics;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth != 0) return false;
        if (notification is ScrollUpdateNotification && widget.onPageChanged != null) {
          final PageMetrics metrics = notification.metrics;
          int currentPage = _lastReportedPage;

          /// Custom change to test for 0.999 instead of 0.5.
          if (metrics.page > currentPage + 0.999 || metrics.page < currentPage - 0.999) {
            currentPage = metrics.page.round();
          }
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged(currentPage);
          }
        }
        if (notification is ScrollStartNotification && widget.onScrollStarted != null) {
          widget.onScrollStarted();
        }
        if (notification is ScrollEndNotification && widget.onScrollEnded != null) {
          widget.onScrollEnded();
        }
        return false;
      },
      child: Scrollable(
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            cacheExtent: widget.cacheExtent,
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              SliverFillViewport(
                  viewportFraction: widget.controller.viewportFraction, delegate: widget.childrenDelegate),
            ],
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    description.add(FlagProperty('reverse', value: widget.reverse, ifTrue: 'reversed'));
    description.add(DiagnosticsProperty<PageController>('controller', widget.controller, showName: false));
    description.add(DiagnosticsProperty<ScrollPhysics>('physics', widget.physics, showName: false));
    description.add(FlagProperty('pageSnapping', value: widget.pageSnapping, ifFalse: 'snapping disabled'));
  }
}
