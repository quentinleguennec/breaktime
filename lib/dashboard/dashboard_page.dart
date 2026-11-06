import 'package:aebeze/app_constants.dart';
import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/dashboard/dashboard_bottom_nav_bar.dart';
import 'package:aebeze/dashboard/dashboard_presenter.dart';
import 'package:aebeze/dashboard/treatment_animated_image.dart';
import 'package:aebeze/dashboard/treatment_list_item.dart';
import 'package:aebeze/dashboard/widgets/page_background.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/safe_state.dart';
import 'package:aebeze/widgets/top_bars/dashboard_top_bar.dart';
import 'package:aebeze/widgets/treatment_box_inflate_animation_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DashboardPage extends MaterialPageRoute<Null> {
  final bool preventTransitionAnimation;

  @override
  Duration get transitionDuration =>
      preventTransitionAnimation ? const Duration(milliseconds: 1) : super.transitionDuration;

  DashboardPage({this.preventTransitionAnimation = false})
      : super(
          builder: (_) => _PageLayout(),
          settings: TrackingService.dashboardPage,
        );
}

class DashboardPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PageLayout();
}

class _PageLayout extends StatefulWidget {
  @override
  _PageLayoutState createState() => _PageLayoutState();
}

class _PageLayoutState extends BasePresenter<_PageLayout>
    with TickerProviderStateMixin
    implements DashboardPagePresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardPagePresenter presenter;
  AnimationController boxSelectedAnimationController;
  AnimationController boxSelectedOpacityAnimationController;
  Animation<double> boxOverlayInflateAnimation;
  Animation<double> boxOverlayTextFadeAnimation;
  Animation<double> boxOverlayFadeAnimation;
  OverlayEntry boxSelectedAnimationOverlay;
  TreatmentListItemRenderBoxDataForAnimation selectedBoxData;

  _PageLayoutState() {
    presenter = DashboardPagePresenter(this);
  }

  @override
  void initState() {
    super.initState();
    presenter.subscribeEvents();

    boxSelectedAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    boxSelectedAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onTreatmentBoxOverlayInflated();
      }
    });
    boxOverlayTextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: boxSelectedAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    boxOverlayInflateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: boxSelectedAnimationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    boxSelectedOpacityAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    boxOverlayFadeAnimation = Tween(begin: 1.0, end: 0.0).animate(boxSelectedOpacityAnimationController);

    boxSelectedAnimationOverlay = OverlayEntry(
      opaque: false,
      builder: (_) => InflateAnimationOverlay(
        inflateAnimation: boxOverlayInflateAnimation,
        opacityAnimation: boxSelectedOpacityAnimationController,
        textOpacityAnimation: boxOverlayTextFadeAnimation,
        boxData: selectedBoxData,
      ),
    );
  }

  @override
  void dispose() {
    boxSelectedAnimationController?.dispose();
    presenter.unsubscribeEvents();
    super.dispose();
  }

  void updateDashboard() => refreshState();

  void onTreatmentBoxOverlayInflated() {
    presenter.openTreatment(
      selectedBoxData.treatment,
      onTreatmentCompleted: () => refreshState(),
      isRecommendedTreatment: selectedBoxData.isRecommended,
    );
    boxSelectedOpacityAnimationController.forward().then((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        boxSelectedAnimationOverlay.remove();
        boxSelectedAnimationController.reset();
        boxSelectedOpacityAnimationController.reset();
      });
    });
  }

  void onTreatmentSelected(TreatmentListItemRenderBoxDataForAnimation data) {
    selectedBoxData = data;
    Overlay.of(context).insert(boxSelectedAnimationOverlay);
    boxSelectedAnimationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            key: _scaffoldKey,
            body: Stack(
              children: <Widget>[
                DashboardPageBackground(),
                Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      height: MediaQuery.of(context).size.height - DashboardBottomNavBar.height,
                      child: DashboardBody(
                        treatments: presenter.treatments,
                        recommendedTreatmentType: presenter.recommendedTreatmentType,
                        onTreatmentSelected: onTreatmentSelected,
                        getTreatmentDayToShow: presenter.getTreatmentDayToShow,
                      ),
                    ),
                    DashboardBottomNavBar(
                      onCheckInPressed: presenter.openMoodSelector,
                      onHistoryPressed: pushMoodTracker,
                      onPillcastPressed: pushPillcast,
                      onUserAccountPressed: presenter.openUserAccountPage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class DashboardBody extends StatefulWidget {
  final String recommendedTreatmentType;
  final ValueSetter<TreatmentListItemRenderBoxDataForAnimation> onTreatmentSelected;
  final Map<String, List<Treatment>> treatments;
  final Function getTreatmentDayToShow;

  DashboardBody({
    @required this.onTreatmentSelected,
    @required this.recommendedTreatmentType,
    @required this.treatments,
    @required this.getTreatmentDayToShow,
  });

  @override
  _DashboardBodyState createState() => _DashboardBodyState();
}

class _DashboardBodyState extends SafeState<DashboardBody> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController?.dispose();
    super.dispose();
  }

  List<List<Treatment>> get allTreatmentsList {
    Map<String, List<Treatment>> allTreatments = Map.of(widget.treatments);
    allTreatments.remove(widget.recommendedTreatmentType);
    return allTreatments.values.toList();
  }

  // (All treatments - the one of the recommended type) + the recommended one + TopBar + All treatments header.
  int get listViewItemCount => widget.treatments.length + 3;

  Widget buildListItem(BuildContext context, int index) {
    if (index == 0) {
      return DashboardTopBar();
    } else if (index == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 12, left: bigPadding),
        child: Text(
          localize(context, "dashboard_featured_treatment"),
          style: AppTextStyles.captionZirkonRegular.copyWith(
            color: AppColors.baseColorVeryFaded,
            fontSize: 15,
          ),
        ),
      );
    } else if (index == 2) {
      return TreatmentListItem(
        scrollController: scrollController,
        treatment: widget.getTreatmentDayToShow(widget.recommendedTreatmentType),
        screenWidth: MediaQuery.of(context).size.width,
        onSelected: widget.onTreatmentSelected,
        boxAlignment: TreatmentListItemAlignment.left,
        isRecommended: true,
      );
    } else if (index == 3) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12, left: bigPadding),
        child: Text(
          localize(context, "dashboard_all_treatments"),
          style: AppTextStyles.captionZirkonRegular.copyWith(
            color: AppColors.baseColorVeryFaded,
            fontSize: 15,
          ),
        ),
      );
    }
    return TreatmentListItem(
      scrollController: scrollController,
      treatment: widget.getTreatmentDayToShow(
        allTreatmentsList[index - (listViewItemCount - allTreatmentsList.length)].first.type,
      ),
      screenWidth: MediaQuery.of(context).size.width,
      onSelected: widget.onTreatmentSelected,
      isRecommended: false,
    );
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: listViewItemCount,
        controller: scrollController,
        itemBuilder: (context, index) => buildListItem(context, index),
      );
}
