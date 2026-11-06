import 'package:aebeze/app_i18n.dart';
import 'package:aebeze/assets.dart';
import 'package:aebeze/services/model.dart';
import 'package:aebeze/services/tracking_service.dart';
import 'package:aebeze/tester/tester_dashboard.dart';
import 'package:aebeze/tester/tester_page_presenter.dart';
import 'package:aebeze/theme.dart';
import 'package:aebeze/widgets/base_presenter.dart';
import 'package:aebeze/widgets/progress_loader.dart';
import 'package:aebeze/widgets/text_scaled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TesterRoute extends MaterialPageRoute<Null> {
  final bool preventTransitionAnimation;

  @override
  Duration get transitionDuration =>
      preventTransitionAnimation ? const Duration(milliseconds: 1) : super.transitionDuration;

  TesterRoute({this.preventTransitionAnimation = false})
      : super(
          builder: (_) => TesterPage(),
          settings: TrackingService.testerPage,
        );
}

class TesterPage extends StatefulWidget {
  @override
  _TesterPageState createState() => _TesterPageState();
}

enum TestMode { cards, treatments }

class _TesterPageState extends BasePresenter<TesterPage> implements TesterPagePresenterView {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TesterPagePresenter presenter;
  List<DataCard> cards;
  Map<String, List<Treatment>> treatments;
  TestMode mode = TestMode.treatments;

  _TesterPageState() {
    presenter = TesterPagePresenter(this);
  }

  @override
  void initState() {
    super.initState();
    presenter.loadData();
  }

  @override
  GlobalKey<ScaffoldState> getScaffoldKey() => _scaffoldKey;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: buildAppBar(),
        body: cards != null ? buildList() : buildLoading(),
      );

  Container buildLoading() => Container(child: Center(child: ProgressLoader()));

  Widget buildList() => mode == TestMode.cards ? buildCardsList() : buildTreatments();

  buildCardsList() => ListView(
      scrollDirection: Axis.vertical,
      children: cards.map((card) => DataCardItem(card, presenter.onDataCardSelected)).toList());

  buildAppBar() => AppBar(
        leading: Padding(padding: const EdgeInsets.all(16.0), child: Image.asset(Assets.headerBadge)),
        centerTitle: false,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: TextScaled(
          localize(context, "app_name"),
          style: AppTextStyles.bodyReg,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              mode = mode == TestMode.cards ? TestMode.treatments : TestMode.cards;
              presenter.loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => presenter.loadData(),
          ),
        ],
      );

  @override
  showCards(List<DataCard> cards) => setMountedState(() => this.cards = cards);

  @override
  showTreatments(Map<String, List<Treatment>> treatments) => setMountedState(() => this.treatments = treatments);

  buildTreatments() => TesterDashboard(treatments, presenter.onTreatmentSelected);
}

typedef OnDataCardSelected(DataCard card);

class DataCardItem extends StatelessWidget {
  final DataCard dataCard;
  final OnDataCardSelected onDataCardSelected;

  DataCardItem(this.dataCard, this.onDataCardSelected);

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: () => onDataCardSelected(dataCard), child: buildContent());

  buildContent() => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                child: TextScaled(
                  dataCard.description == null ? "Undefined" : dataCard.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
            Row(children: <Widget>[
              Expanded(
                child: TextScaled(
                  dataCard.type == null ? "UNDEFINED" : dataCard.type.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(color: const Color(0xFFF75F33)),
                ),
              )
            ]),
          ],
        ),
      );
}
